# RSS.rocks!

RSS email notifier app, backed by Firebase.

This is a experiment app aims to help figure out how Firebase API works and what kind of projects could be achived with its help.

## Firebase Rules

(not tested, and seems to be not working)

    {
      "rules": {
        ".read": true,
        "feeds": {
          "$feed": {
            ".write": "auth != null",
            ".validate": "auth.id == newData.child('userid').val() && newData.hasChildren(['userid', 'url', 'name']) && newData.child('url').isString() && newData.child('name').isString()"
          }
        }
      }
    }