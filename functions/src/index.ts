import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";
admin.initializeApp();

export const onConnectionRequest = functions
  .region("asia-south1")
  .firestore
  .document("connection_requests/{requestId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const fromUsername = data.fromUsername;
    const toUsername = data.toUsername;
    const now = admin.firestore.FieldValue.serverTimestamp();

    if (!fromUsername || !toUsername || fromUsername === toUsername) {
      console.log("Invalid usernames.");
      return null;
    }

    const getProfileDoc = async (username: string) => {
      const usernameDoc = await admin.firestore().collection("usernames").doc(username).get();
      if (!usernameDoc.exists) throw new Error(`Username ${username} not found`);
      const uid = usernameDoc.data()?.uid;
      return {
        uid,
        profileSnap: await admin.firestore()
          .collection("users").doc(uid)
          .collection("profiles").doc(username)
          .get()
      };
    };

    const [{ uid: fromUid, profileSnap: fromUserSnap }, { uid: toUid, profileSnap: toUserSnap }] =
      await Promise.all([getProfileDoc(fromUsername), getProfileDoc(toUsername)]);

    if (!fromUserSnap.exists || !toUserSnap.exists) {
      console.log("One or both profiles not found.");
      return null;
    }

    const fromUser = fromUserSnap.data();
    const toUser = toUserSnap.data();

    const extractProfile = (user: any) => ({
      name: user.name || "",
      profilePicUrl: user.profilePicUrl || "",
      jobTitle: user.jobTitle || "",
      organisation: user.organisation || "",
    });

    const fromUserConnectionRef = admin.firestore()
      .collection("users").doc(fromUid)
      .collection("profiles").doc(fromUsername)
      .collection("connections").doc(toUsername);

    const toUserConnectionRef = admin.firestore()
      .collection("users").doc(toUid)
      .collection("profiles").doc(toUsername)
      .collection("connections").doc(fromUsername);

    const [fromConnSnap, toConnSnap] = await Promise.all([
      fromUserConnectionRef.get(),
      toUserConnectionRef.get(),
    ]);

    if (!fromConnSnap.exists) {
      await fromUserConnectionRef.set({
        since: now,
        username: toUsername,
        ...extractProfile(toUser),
      });
    }

    if (!toConnSnap.exists) {
      await toUserConnectionRef.set({
        since: now,
        username: fromUsername,
        ...extractProfile(fromUser),
      });
    }

    await snap.ref.delete();

    console.log(`Mutual connection established between ${fromUsername} and ${toUsername}`);
    return null;
  });

export const onUserProfileUpdate = functions
  .region("asia-south1")
  .firestore
  .document("users/{uid}/profiles/{username}")
  .onUpdate(async (change, context) => {
    const after = change.after.data();
    const before = change.before.data();
    const username = context.params.username;
    const uid = context.params.uid;

    const fields = ["name", "profilePicUrl", "jobTitle", "organisation"];
    const changed = fields.some((f) => after[f] !== before[f]);
    if (!changed) {
      return null;
    }

    const connectionsRef = change.after.ref.collection("connections");
    const connectionsSnap = await connectionsRef.get();

    const updateData = {
      name: after.name || "",
      profilePicUrl: after.profilePicUrl || "",
      jobTitle: after.jobTitle || "",
      organisation: after.organisation || "",
    };

    const batch = admin.firestore().batch();
    connectionsSnap.forEach((doc) => {
      batch.update(doc.ref, updateData);
    });

    await batch.commit();
    console.log(`Updated profile fields in all connections for ${username}`);
    return null;
  });

export const deleteConnection =
  functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "You must be logged in");
    }

    const currentUserUid = context.auth.uid;
    const currentUsername = data.username;
    const connectionUsername = data.connectionUsername;

    if (!currentUsername || !connectionUsername) {
      throw new functions.https.HttpsError("invalid-argument", "Missing username or connectionUsername");
    }

    try {
      const connectionUsernameDoc = await admin.firestore()
        .collection("usernames")
        .doc(connectionUsername)
        .get();

      if (!connectionUsernameDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Connection username mapping not found");
      }

      const connectionUid = connectionUsernameDoc.data()?.uid;

      const batch = admin.firestore().batch();

      const userConnectionRef = admin.firestore()
        .collection("users").doc(currentUserUid)
        .collection("profiles").doc(currentUsername)
        .collection("connections").doc(connectionUsername);
      batch.delete(userConnectionRef);

      const otherConnectionRef = admin.firestore()
        .collection("users").doc(connectionUid)
        .collection("profiles").doc(connectionUsername)
        .collection("connections").doc(currentUsername);
      batch.delete(otherConnectionRef);

      await batch.commit();

      return { success: true };
    } catch (error) {
      console.error("Error deleting connection:", error);
      if (error instanceof functions.https.HttpsError) throw error;
      throw new functions.https.HttpsError("internal", "Failed to delete connection");
    }
  });
