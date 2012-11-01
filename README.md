# Passbook-Ruby

[![Build Status](https://secure.travis-ci.org/xtremelabs/xl-passbook-ruby.png)](http://travis-ci.org/xtremelabs/xl-passbook-ruby)

[Passbook] is an app distributed on iOS6.
This is an implementation for management and signing of pkpasses for your Rails application.
The management of templates and all the other data is done in-memory. This gem does not write to the filesystem. This results in a speed boost.

Quick Start Video:
http://www.youtube.com/watch?v=GeWFk1FvEKc

## Usage

### Install

```
gem 'passbook-ruby'
bundle
```
### P12 certificate
This the first of 2 certificates you need to sign a pkpass.
[Apple has a step-by-step] for most of it. You can pick up from step 7.
Alternatively, you can follow all of my steps:

1. Go to <b>[iOS Provisioning Portal]</b> (you need to login or register)
* Click on <b>"Pass Type IDs"</b> on the left side menu
* Click on <b>"New Pass Type ID"</b> and fill in the 2 fields
* After you come back to the listing of pass type ids, click on <b>"Configure"</b> link next to the one you created
* Click on <b>Configure</b> button and <b>follow the instructions</b> in the wizard
* Once you <b>download</b> the pass.cer, double-click to <b>install</b>
* In the "Keychain Access" tool <b>right-click</b> on Pass Type ID: <you.pass.id> and click <b>"Export "Pass Type .....""</b>
* Change "File Format" to "Personal Information Exchange(.p12)" and <b>save</b> (preferably to Rails.root/data/certificates/)
* The password you enter during the saving process will go into the initializer ("Run Generator" step)

### WWDR Certificate
Second certificate you need to sign a pkpass

1. <b>Download</b> http://developer.apple.com/certificationauthority/AppleWWDRCA.cer
* Double-click to <b>install</b>
* In the "Keychain Access" tool <b>right-click</b> on "Apple Worldwide Developer Relations Certification Authority" and click on <b>Export "Apple....</b>
* Change "File Format" to "Privacy Enhanced Mail (.pem)" and <b>save</b> it (preferably to Rails.root/data/certificates/)

### Run generators
All the <b>parameters are optional</b>. You can just edit the initializer later
```
   rails g passbook:config [wwdr_certificate_path]
```
That creates an initializer and a migration.
Don't forget to put the WWDR certificate into the path now, if you used the defaults.


After that, let's create a pkpass model (ie. ticket).
I would strongly advise specifying **model_name**, **pass_type_id** and **tead_id** at this points.

```
   rails g passbook:pkpass [model_name] [pass_type_id] [team_id] [cert_path] [cert_password]
```
This will generate a model, a migration, an initializer, a route and a sample pass (to data/templates/your_pass_type_id). Make sure to add your
.p12 into the path now if you use the defaults. Also, if you didn't set the password for the cert in the above command, make sure you change the default to
your password in config/initializers/passbook_#{model_name}.rb.


```
   rake db:migrate
   rails s
```
and go to \passes\model_name on your iphone (make sure it is in debug mode and allows http connections)



#### Check out [FAQs] wiki section if you get in trouble

####Thank you for help:
Dwayne Forde, Cody Veal, Gregory Chow, Vincent Lee, Hussam Sheikh, Tanzeeb Khalili, Vincent Coste


####Lisence

Except as otherwise noted, the Passbook-Ruby gem is licensed under the [Apache License, Version 2.0]


  [passbook]: https://developer.apple.com/passbook/
  [iOS Provisioning Portal]: https://developer.apple.com/devcenter/ios/index.action
  [Apple has a step-by-step]: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/PassKit_PG/Chapters/YourFirst.html#//apple_ref/doc/uid/TP40012195-CH2-SW27
  [Pass Design and Creation]: https://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/PassKit_PG/Chapters/Creating.html#//apple_ref/doc/uid/TP40012195-CH4-SW1
  [Apple documentation]: https://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/PassKit_PG/Chapters/Introduction.html
  [Download a sample]: https://github.com/downloads/xtremelabs/xl-passbook-ruby/pass.com.acme.zip
  [FAQs]: https://github.com/xtremelabs/xl-passbook-ruby/wiki/faqs
  [teamIdentifier]: https://github.com/xtremelabs/xl-passbook-ruby/wiki/faqs
  [Apache License, Version 2.0]: http://www.apache.org/licenses/LICENSE-2.0.html
