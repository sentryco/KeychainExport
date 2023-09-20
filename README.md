[![Tests](https://github.com/sentryco/KeychainExport/actions/workflows/Tests.yml/badge.svg)](https://github.com/sentryco/KeychainExport/actions/workflows/Tests.yml)

# KeychainExport 📦
This tool allows you to export General Passwords and Secure Notes from the Apple Keychain on macOS.

### Export Format:
The first item in the exported data represents a Secure Note, while the second represents a General Password. Please note that a Secure Note will never contain a password.
```json
[
  {
    "note" : "ecwecwec",
    "password" : "",
    "type" : "note",
    "title" : "affinity"
  },
  {
    "note" : "",
    "password" : "wewcwcwe",
    "type" : "password",
    "title" : "john@hotmail.com"
  }
]
```
### UI / UX

<img width="532" alt="Screenshot 2020-09-10 at 20 42 22" src="https://user-images.githubusercontent.com/11816788/92785277-900bc580-f3a7-11ea-819a-a435e7dee855.png">

<img width="532" alt="Screenshot 2020-09-10 at 20 42 29" src="https://user-images.githubusercontent.com/11816788/92785407-afa2ee00-f3a7-11ea-9325-d485ee676b57.png">

<img width="532" alt="Screenshot 2020-09-10 at 20 44 27" src="https://user-images.githubusercontent.com/11816788/92785507-c47f8180-f3a7-11ea-9dc6-be1e576344df.png">

<img width="546" alt="Screenshot 2020-09-10 at 20 42 33" src="https://user-images.githubusercontent.com/11816788/92785567-d103da00-f3a7-11ea-9ab2-5ab3d9e6ed69.png">

<img width="459" alt="Screenshot 2020-09-10 at 20 43 46" src="https://user-images.githubusercontent.com/11816788/92785644-e11bb980-f3a7-11ea-9b04-498bb3d3982b.png">

### Todo:
- Design a macOS icon for submission to AppStore etc 👈
- Add readable error
- Reset git before making the repo public, it has Key repo etc, also tokens that should be cleared ✅
- what format is it saved in?
