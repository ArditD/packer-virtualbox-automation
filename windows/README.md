# Templates for automated Windows 10 (build 1809 and 1909 or later) and Windows server 2016 / 2019 Datacenter
- The connection between packer and the virtual systems is done via WinRM over SSL with a self signed
certificate generated during the installation. The port used on the guest is 5986 while on the host
is randomly generated.
The heavy lifting is done directly in Autounattend.xml creating this way a very stable and simple design.
- GuestAdditions are automatically set up during the installation, of course, with screen resize
/ drag & drop / bidirectional copy already working.
### WARNING : make sure you have virtualbox-guest-iso installed on your host.
The oracle.cer expires in 2022 (needed otherwise it will fail the driver / device installation.)
```
        Version: 3 (0x2)
        Serial Number:
            05:30:8b:76:ac:2e:15:b2:97:20:fb:43:95:f6:5f:38
        Signature Algorithm: sha1WithRSAEncryption
        Issuer: C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Assured ID Code Signing CA-1
        Validity
            Not Before: Mar 19 00:00:00 2019 GMT
            Not After : Mar 23 12:00:00 2022 GMT
        Subject: C = US, ST = CA, L = Redwood Shores, O = Oracle Corporation, OU = Virtualbox, CN = Oracle Corporation
        Subject Public Key Info:
```
- RDP is by default enabled on all systems for easy access or for switchboard testing.
- Automatic Login with Administrator or qacicd depending if you are on the servers or on windows 10.
- The builds have been tested and curated quite few times ;)
- Note, the windows10-build1909 will work also with the latest windows builds, so just replace the hash/iso.
