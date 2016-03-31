# osc-user-map

The user mapping script employed by OSC for OnDemand and AweSim.


While using Google for authentication, to get the id, you can do one of two
ways:

1. login to your google account, then try to access an app i.e. http://websvcs08.osc.edu:5000/pun/dev/foo or http://websvcs08.osc.edu:5000/pun/shared/efranz/dashboard. The id will be displayed here:

    user doesn't exist: 109838079349976181632accounts.google.com

2. go to your google plus page and you'll see a link like this: https://plus.google.com/109838079349976181632/posts - the long number is your id

Once you have the id you can update the bin/osc-user-map file
