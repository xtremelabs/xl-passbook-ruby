# Passbook-Ruby

[Passbook] is an app distributed on iOS6.
This is an implementation for management and signing of pkpasses for your Rails application.
The management of templates and all the other data is done in-memory. This gem does not write to the filesystem. This results in a speed boost.

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
* Change "File Format" to "Personal Information Exchange(.p12)" and <b>save</b> (preferably in Rails.root/data/certificates/)
* The password you enter during the saving process will go into the initializer ("Run Generator" step)

### WWDR Certificate
Second certificate you need to sign a pkpass
1. <b>Download</b> http://developer.apple.com/certificationauthority/AppleWWDRCA.cer
* Double-click to <b>install</b>
* In the "Keychain Access" tool <b>right-click</b> on "Apple Worldwide Developer Relations Certification Authority" and click on <b>Export "Apple....</b>
* Change "File Format" to "Privacy Enhanced Mail (.pem)" and <b>save</b> it (preferably in Rails.root/data/certificates/)

## Run generator
All the <b>parameters are optional</b>. You can just edit the initializer later
```
   rails g passbook:config [pass_type_id] [template_path] [cert_path] [cert_password] [wwdr_certificate_path]
```
that will create an initializer passbook-ruby.rb in config/initializers/ that look like the following (by default):
```
Passbook::Config.instance.configure do |passbook|
  passbook.pass_config['pass.com.acme']={
                              "cert_path"=>'{Rails.root}/data/certificates/pass.com.acme.p12',
                              "cert_password"=>'password',
                              "template_path"=>'#{Rails.root}/data/templates/pass.com.acme'
                            }

  passbook.wwdr_intermediate_certificate_path= '#{Rails.root}/data/certificates/wwdr.pem'
end
```

## Create a template
Download a sample template or create one yourself
![Pkpass structure](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/PassKit_PG/Art/directory_structure_2x.png)



  [passbook]: https://developer.apple.com/passbook/
  [iOS Provisioning Portal]: https://developer.apple.com/devcenter/ios/index.action
  [Apple has a step-by-step]: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/PassKit_PG/Chapters/YourFirst.html#//apple_ref/doc/uid/TP40012195-CH2-SW27


