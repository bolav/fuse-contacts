using Uno;
using Uno.Collections;
using Fuse;
using Bolav.ForeignHelpers;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;

[Require("Source.Import","AddressBook/AddressBook.h")]
[Require("Xcode.Framework", "AddressBook")]
public extern(iOS) class ContactsImpl
{
	public static Future<string> AuthorizeImpl()
	{
		var p = new Promise<string>();
		var status = GetAuthorizationStatus();
		if (status == "AuthorizationNotDetermined") {
			var closure = new AuthorizationClosure(p);
			closure.RequestAuthorization();
			return p;
		}
		p.Resolve(status);
		return p;
	}

	[Foreign(Language.ObjC)]
	public static string GetAuthorizationStatus()
	@{
		ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();

		if (status == kABAuthorizationStatusDenied) {
			return @"AuthorizationDenied";
		}
		else if (status == kABAuthorizationStatusRestricted) {
			return @"AuthorizationRestricted";
		}
		else if (status == kABAuthorizationStatusNotDetermined) {
			return @"AuthorizationNotDetermined";
		}
		else if (status == kABAuthorizationStatusAuthorized) {
			return @"AuthorizationAuthorized";
		}
		else {
			return @"Unknown";
		}
	@}

	// http://stackoverflow.com/questions/3747844/get-a-list-of-all-contacts-on-ios
	[Foreign(Language.ObjC)]
	public static void GetAllImpl(ListDict ret) 
	@{
		CFErrorRef error = NULL;
		ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
		CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
		// CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
		CFIndex nPeople = CFArrayGetCount(allPeople);

		for ( int i = 0; i < nPeople; i++ )
		{
			@{ListDict:Of(ret).NewRowSetActive():Call()};
		    ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
		    @{ListDict:Of(ret).SetRow_Column(string,string):Call(@"firstName", CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty)))};
		    @{ListDict:Of(ret).SetRow_Column(string,string):Call(@"lastName", CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty)))};
		    @{ListDict:Of(ret).SetRow_Column(string,string):Call(@"organization", CFBridgingRelease(ABRecordCopyValue(person, kABPersonOrganizationProperty)))};
		    // @{ListDict:Of(ret).SetRow_Column(string,string):Call(@"email", CFBridgingRelease(ABRecordCopyValue(person, kABPersonEmailProperty)))};
		}
		CFRelease(allPeople);
	@} 
}

[Require("Source.Import","AddressBook/AddressBook.h")]
public extern(iOS) class AuthorizationClosure {
	Promise<string> promise;
	public AuthorizationClosure(Promise<string> p) {
		promise = p;
	}

	public void Resolve(string s) {
		promise.Resolve(s);
	}

	[Foreign(Language.ObjC)]
	public void RequestAuthorization() 
	@{
		CFErrorRef error = NULL;
		ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
		if (!addressBook) {
		    NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
			@{AuthorizationClosure:Of(_this).Resolve(string):Call(@"Error getting addressBook")};
		    return;
		}

		ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
		    if (error) {
		        NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
		        @{AuthorizationClosure:Of(_this).Resolve(string):Call(@"Error getting access")};
		    }

		    if (granted) {
		        @{AuthorizationClosure:Of(_this).Resolve(string):Call(@"AuthorizationAuthorized")};
		    } else {
		    	@{AuthorizationClosure:Of(_this).Resolve(string):Call(@"AuthorizationDenied")};
		    }
		    CFRelease(addressBook);
		});
	@}

}