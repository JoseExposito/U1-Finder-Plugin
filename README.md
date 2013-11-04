**Follow U1 Finder Plugin on...** [![](https://lh3.googleusercontent.com/-kRgKvb-T4_4/T9psNwZN3TI/AAAAAAAAANA/pwasxapdWm0/s33/twitter.png "Twitter")](https://twitter.com/#!/Jose__Exposito)

About U1 Finder Plugin:
=======================

_U1 Finder Plugin_ allows to the **OS X** users to add integration with Ubuntu One in their Finder application, showing an icon overlay with the state of your synchronized files and adding Ubuntu One features to the context menu.

<p align="center">
	<img src="https://pbs.twimg.com/media/BFnAJN2CMAAzNmw.png:large" width="649" height="409">
</p>

Compilation and installation:
=============================

Download as zip, clone or fork the U1 Finder Plugin source code, open it with Xcode and build the "U1 Finder Injector" target. This will generate two products: "U1 Finder Plugin.bundle" and "U1 Finder Injector.osax".
Copy the "U1 Finder Injector.osax" bundle to "/Library/ScriptingAdditions" or "~/Library/ScriptingAdditions" and stop Finder:

    $ osascript -e "tell application \"Finder\" to quit"

Then you will be able to load the U1 Finder Plugin with this Apple script:

    tell application "Finder"
	delay 1
	try
		«event UONEload»
    	on error msg number num
    		display dialog "Error loading U1 Finder Plugin"
    	end try
    end tell


Launch the /Applications/Utilities/Console.app to see the plugin output.


Copyright:
==========

Copyright (C) 2012 José Expósito <<jose.exposito89@gmail.com>> 

The source code is available under GPL v2 license at [GitHub](https://github.com/JoseExposito/U1-Finder-Plugin)


Helping to the project:
=======================

Below you can see many ways to collaborate easily with _U1 Finder Plugin_ project, as you
can see collaborate is very easy.

+ **Sending suggestions**

 Are you _U1 Finder Plugin_ user and think that the project need something? Do not hesitate, let me know!


+ **Reporting bugs**

 Have you found a bug? Report it!

+ **Advertising _U1 Finder Plugin_ project**

 If you have a blog, a website, a Facebook or Twitter account or some similar, a good way to help the project is making it known to more users


+ **Making a donation**

 Finally if you can not help none of the above, you can always make a donation, even a few pennies to help the project continue forward

 [![](https://www.paypal.com/en_US/i/btn/btn_donateCC_LG.gif "Make a donation")](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=FT2KS37PVG8PU&lc=US&item_name=Egg%20Software&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)
