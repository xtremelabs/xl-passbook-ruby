Passbook-Ruby
=============
[Passbook] is an app distributed on iOS6.
This is an implementation for management and signing of pkpasses for your Rails application.
The management of templates and all the other data is done in-memory. This gem does not write to the filesystem. This results in a speed boost.

Usage
-----
1. Install
-
* gem 'passbook-ruby'
* bundle

2. P12 certificate
-
Apple has a step-by-step for this [HERE].
Alternatively, you can follow my steps:

* Go to <b>[iOS Provisioning Portal]</b> (you need to login or register)
* Click on <b>"Pass Type IDs"</b> on the left side menu
* Click on <b>"New Pass Type ID"</b> and fill in the 2 fields
* After you come back to the listing of pass type ids, click on <b>"Configure"</b> link next to the one you created
* Click on <b>Configure</b> button and <b>follow the instructions</b> in the wizard
* Once you <b>download</b> the pass.cer, double-click to <b>install</b>
* In the "Keychain Access" tool <b>right-click</b> on Pass Type ID: <you.pass.id> and click <b>"Export "Pass Type .....""</b>
* Change "File Format" to "Personal Information Exchange(.p12)" and <b>save</b> (preferably in Rails.root/data/certificates/)

3. WWDR Certificate
-
* Download http://developer.apple.com/certificationauthority/AppleWWDRCA.cer
* Double-click to install
* In the "Keychain Access" tool right-click on "Apple Worldwide Developer Relations Certification Authority" and click on Export "Apple....
* Change "File Format" to "Privacy Enhanced Mail (.pem)" and save it (preferably in Rails.root/data/certificates/)

4. Run generator
-

5. Create a template
-



  [passbook]: https://developer.apple.com/passbook/
  [iOS Provisioning Portal]: https://developer.apple.com/devcenter/ios/index.action
  [HERE]: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/PassKit_PG/Chapters/YourFirst.html#//apple_ref/doc/uid/TP40012195-CH2-SW27
