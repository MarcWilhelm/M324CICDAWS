# CI/CD Pipeline für eine React-Anwendung mit Docker Hub

Diese README beschreibt die Konfiguration einer CI/CD-Pipeline, die auf jede Änderung im `main`-Branch reagiert, die Anwendung baut und ein Docker-Image erstellt und auf Docker Hub veröffentlicht.

## Voraussetzungen

Bevor du mit dieser Pipeline arbeitest, benötigst du:

- **Docker Hub Konto**: Für die Veröffentlichung des Docker-Images.
- **GitHub Repository**: Für den Quellcode der React-Anwendung.
- **GitHub Secrets**: Füge dein Docker Hub-Username (`DOCKER_USERNAME`) und Passwort (`DOCKER_PASSWORD`) als GitHub Secrets in deinem Repository hinzu.

## Schritte der Pipeline

Die Pipeline führt die folgenden Schritte durch:

1. **Checkout Code**  
   Der Quellcode wird aus dem GitHub-Repository ausgecheckt. Dies stellt sicher, dass der neueste Stand der Anwendung für den Build-Prozess verfügbar ist.

2. **Set up Node.js**  
   Node.js wird installiert, um die Abhängigkeiten der React-Anwendung zu verwalten und die App zu bauen. Hier wird Node.js in der Version 16 verwendet, dies kann je nach Projektanforderungen angepasst werden.

3. **Install Dependencies**  
   Dieser Schritt installiert alle Abhängigkeiten der Anwendung mittels `npm install`. Dadurch werden alle Bibliotheken und Pakete, die in der `package.json` definiert sind, installiert.

4. **Build the React App**  
   Die Anwendung wird mit `npm run build` gebaut, um eine Produktionsversion zu erstellen. Dieser Schritt generiert die optimierten Dateien für den Einsatz in der Produktion.

5. **Log in to Docker Hub**  
   Die Pipeline meldet sich bei Docker Hub an, um das erstellte Docker-Image später hochladen zu können. Die Anmeldedaten werden aus den GitHub Secrets (`DOCKER_USERNAME` und `DOCKER_PASSWORD`) abgerufen.

6. **Build Docker Image**  
   Das Docker-Image wird erstellt. Hier wird der Befehl `docker build` ausgeführt, wobei das Image auf Basis des Dockerfiles erstellt wird. Das Image wird mit dem Namen `react-app:latest` markiert und dem Docker Hub-Benutzernamen vorangestellt.

7. **Push Docker Image to Docker Hub**  
   Das erstellte Docker-Image wird in das Docker Hub Repository hochgeladen, damit es dort gespeichert und später von anderen Umgebungen abgerufen werden kann.

8. **Abschluss des Jobs**  
   Nach erfolgreicher Ausführung aller Schritte wird der Job abgeschlossen.

## Pipeline-Konfigurationsdatei (ci.yml)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '16' # Passe die Node.js-Version nach Bedarf an

      - name: Install dependencies
        run: npm install

      - name: Build the React app
        run: npm run build

      - name: Log in to Docker Hub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      - name: Build Docker image
        run: docker build . -t ${{ secrets.DOCKER_USERNAME }}/react-app:latest

      - name: Push Docker image to Docker Hub
        run: docker push ${{ secrets.DOCKER_USERNAME }}/react-app:latest
