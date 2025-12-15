# Princess Journey

An intermittent fasting and water intake application.
Made for my wife that was fed up with adverts on commercial apps of the same kind, and for me to get the hang of flutter.

## Upgrade guide

- Regenerate a clean flutter project (see below)
- Upgrade versions in versions.env
- Upgrade flutter dependencies in pubspec.yml
- Upgrade Dockerfile and GitHub actions build.yml
- Upgrade Rust Cargo.toml dependencies

### Regenerate the frontend

```
cd ..
mv princess-journey princess-journey-old
flutter create --template=app --platforms="android,web" --description="An intermittent fasting and water intake flutter application" --org="fr.ninico" --project-name="princess_journey" princess-journey
```
