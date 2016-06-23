Fuse Contacts bindings [![Build Status](https://travis-ci.org/bolav/fuse-contacts.svg?branch=master)](https://travis-ci.org/bolav/fuse-contacts) ![Fuse Version](http://fuse-version.herokuapp.com/?repo=https://github.com/bolav/fuse-contacts)
======================

Library to use contacts in [Fuse](http://www.fusetools.com/).

https://www.fusetools.com/community/forums/feature_requests/contacts_api

Issues, feature request and pull request are welcomed.

## Installation

Using [fusepm](https://github.com/bolav/fusepm)

    $ fusepm install https://github.com/bolav/fuse-contacts


## Usage:

### UX

`<Contacts ux:Global="Contacts" />`


### JS

```
contacts.authorize().then(function (status) {
	console.log(status);
	if (status === 'AuthorizationAuthorized') {
		console.log(JSON.stringify(contacts.getAll()));
	}
})

```

API
---

### require

```
var contacts = require('Contacts');
```

### authorize

Returns a promise with the status of authorization

```
var auth = contacts.authorize();
auth.then(function (status) {
	console.log(status);
})
```

status can be:

- AuthorizationDenied
- AuthorizationRestricted
- AuthorizationAuthorized

(and some error results)

### getAll

Returns an array of hashes of contacts

```
console.log(JSON.stringify(contacts.getAll()));
```
