# Configuration Firebase pour les Notifications Push

Ce document explique comment configurer Firebase Cloud Messaging (FCM) pour recevoir des notifications push sur les téléphones.

## 📋 Prérequis

1. Un projet Firebase configuré
2. L'application Flutter configurée avec Firebase
3. Accès à la console Firebase

## 🔧 Configuration dans Firebase Console

### 1. Activer Cloud Messaging

1. Allez dans la [Console Firebase](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. Dans le menu de gauche, allez dans **"Paramètres du projet"** (icône d'engrenage)
4. Allez dans l'onglet **"Cloud Messaging"**
5. Assurez-vous que **"Cloud Messaging API (V1)"** est activé

### 2. Configurer les clés API (pour Android)

1. Dans **"Cloud Messaging"**, trouvez la section **"Clés serveur"**
2. Si vous n'avez pas de clé, cliquez sur **"Générer une nouvelle clé privée"**
3. Copiez la clé - vous en aurez besoin pour envoyer des notifications depuis votre backend (optionnel)

### 3. Configurer les certificats (pour iOS)

1. Dans **"Cloud Messaging"**, trouvez la section **"Certificats APNs"**
2. Téléchargez votre certificat APNs depuis votre compte développeur Apple
3. Uploadez-le dans Firebase

## 📱 Configuration dans l'Application Flutter

### 1. Ajouter les dépendances

Les dépendances nécessaires sont déjà dans `pubspec.yaml` :
- `firebase_core`
- `firebase_messaging` (à ajouter si pas déjà présent)

Si `firebase_messaging` n'est pas présent, ajoutez-le :

```yaml
dependencies:
  firebase_messaging: ^14.7.9
```

Puis exécutez :
```bash
flutter pub get
```

### 2. Configuration Android

#### android/app/build.gradle

Assurez-vous que la version minimale de SDK est au moins 21 :

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        // ...
    }
}
```

#### android/app/src/main/AndroidManifest.xml

Ajoutez les permissions nécessaires :

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

### 3. Configuration iOS

#### ios/Runner/Info.plist

Ajoutez les permissions pour les notifications :

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## 🚀 Implémentation (Optionnel - pour notifications push)

Si vous voulez recevoir des notifications push sur les téléphones (pas seulement dans l'app), vous devez :

1. **Demander la permission** aux utilisateurs
2. **Obtenir le token FCM** pour chaque appareil
3. **Enregistrer le token** dans Firestore
4. **Envoyer des notifications push** via FCM API

### Exemple de code pour obtenir le token FCM :

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseMessaging _messaging = FirebaseMessaging.instance;

// Demander la permission
NotificationSettings settings = await _messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);

if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  // Obtenir le token
  String? token = await _messaging.getToken();
  
  // Enregistrer le token dans Firestore
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'fcmToken': token});
}
```

## 📝 Notes Importantes

### Notifications dans l'application (déjà implémenté)

✅ **Les notifications dans l'application fonctionnent déjà !**
- Quand une anomalie est créée, tous les utilisateurs reçoivent une notification dans l'onglet "Notifications"
- Quand le statut change, tous les utilisateurs sont notifiés
- Les notifications apparaissent en temps réel grâce à Firestore Streams

### Notifications push (nécessite configuration supplémentaire)

⚠️ **Pour les notifications push sur les téléphones (même quand l'app est fermée) :**
- Vous devez implémenter le code ci-dessus
- Vous devez configurer un backend ou utiliser Cloud Functions pour envoyer les notifications via FCM API
- Cela nécessite une configuration plus avancée

## 🔍 Vérification

Pour vérifier que les notifications fonctionnent :

1. **Dans l'application** :
   - Créez une nouvelle anomalie
   - Vérifiez que tous les utilisateurs voient la notification dans l'onglet "Notifications"
   - Changez le statut d'une anomalie
   - Vérifiez que tous les utilisateurs sont notifiés

2. **Dans Firestore** :
   - Allez dans la collection `notifications`
   - Vous devriez voir une notification pour chaque utilisateur à chaque événement

## 🆘 Dépannage

### Les notifications n'apparaissent pas dans l'app

1. Vérifiez que l'utilisateur est connecté
2. Vérifiez que le document utilisateur existe dans Firestore avec le bon `userId`
3. Vérifiez les règles de sécurité Firestore pour la collection `notifications`
4. Vérifiez la console pour les erreurs

### Les notifications push ne fonctionnent pas

1. Vérifiez que `firebase_messaging` est installé
2. Vérifiez que les permissions sont demandées
3. Vérifiez que le token FCM est enregistré dans Firestore
4. Vérifiez que Cloud Messaging est activé dans Firebase Console

## 📚 Ressources

- [Documentation Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Messaging](https://firebase.flutter.dev/docs/messaging/overview)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

