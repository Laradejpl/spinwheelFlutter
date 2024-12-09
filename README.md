# Spinning Wheel Game
by Larade jean-philippe
Une application Flutter interactive présentant une roue de la fortune avec des effets visuels et sonores. Les utilisateurs peuvent faire tourner la roue pour tenter de gagner différents prix, avec des animations de flammes pendant la rotation et des confettis en cas de gain.

## Fonctionnalités

- Roue interactive avec 8 segments de prix différents
- Animation fluide de rotation
- Effets de particules de feu pendant la rotation
- Confettis lors d'un gain
- Effets sonores pour la rotation et les victoires
- Interface utilisateur intuitive
- Dialogue de résultat personnalisé

## Prérequis

- Flutter (dernière version stable)
- Dart SDK
- Un environnement de développement (Android Studio, VS Code, etc.)

## Installation

1. Clonez le repository :
```bash
git clone [url-du-repository]
```

2. Installez les dépendances en ajoutant ces lignes dans votre `pubspec.yaml` :
```yaml
dependencies:
  flutter:
    sdk: flutter
  audioplayers: ^5.2.1
  confetti: ^0.7.0
```

3. Créez un dossier `assets` à la racine du projet et ajoutez-y les fichiers sons :
   - `spinning_sound.wav` (son de rotation)
   - `victory_sound.wav` (son de victoire)

4. Mettez à jour votre `pubspec.yaml` pour inclure les assets :
```yaml
flutter:
  assets:
    - assets/spinning_sound.wav
    - assets/victory_sound.wav
```

5. Installez les dépendances :
```bash
flutter pub get
```

## Utilisation

1. Lancez l'application :
```bash
flutter run
```

2. Interface utilisateur :
   - Appuyez sur le bouton "TOURNER" pour faire tourner la roue
   - Des flammes apparaîtront autour de la roue pendant la rotation
   - En cas de gain, des confettis tomberont du haut de l'écran
   - Un dialogue affichera votre résultat

## Structure des prix

La roue contient 8 segments avec les prix suivants :
- 500$
- 200$
- 100$
- 50$
- 10$
- 1$
- 0$
- Loose (Perte)

## Personnalisation

Vous pouvez personnaliser plusieurs aspects du jeu :

### Couleurs
- Les segments de la roue sont en bleu, rouge, vert et orange
- Les flammes utilisent un dégradé de jaune à rouge
- Les confettis sont multicolores

### Sons
Vous pouvez remplacer les fichiers sons dans le dossier `assets` par vos propres sons :
- `spinning_sound.wav` pour le son de rotation
- `victory_sound.wav` pour le son de victoire

### Paramètres de jeu
Dans le code, vous pouvez ajuster :
- La durée de rotation (`Duration(seconds: 5)`)
- Les montants des prix (dans la liste `prizes`)
- L'intensité des effets visuels (particules et confettis)

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche pour votre fonctionnalité
3. Commit vos changements
4. Push vers la branche
5. Ouvrir une Pull Request

## License

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

## Contact

Pour toute question ou suggestion, n'hésitez pas à ouvrir une issue dans le repository.