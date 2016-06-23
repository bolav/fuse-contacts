using Uno;
using Fuse;
using Bolav.ForeignHelpers;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;

[Require("Source.Import","AddressBook/AddressBook.h")]
[Require("Source.Include", "@{ForeignDict:Include}")]
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
	public static void GetAllImpl(ForeignList ret) 
	@{
		CFErrorRef error = NULL;
		ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
		CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
		// CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
		CFIndex nPeople = CFArrayGetCount(allPeople);

		for ( int i = 0; i < nPeople; i++ )
		{
			id<UnoObject> row = @{ForeignList:Of(ret).NewDictRow():Call()};
		    ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
		    // https://developer.apple.com/library/ios/documentation/AddressBook/Reference/ABRecordRef_iPhoneOS/
		    @{ForeignDict:Of(row).SetKeyVal(string,string):Call(@"firstName", CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty)))};
		    @{ForeignDict:Of(row).SetKeyVal(string,string):Call(@"lastName", CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty)))};
		    @{ForeignDict:Of(row).SetKeyVal(string,string):Call(@"organization", CFBridgingRelease(ABRecordCopyValue(person, kABPersonOrganizationProperty)))};


		    id<UnoObject> emailList = @{ForeignDict:Of(row).AddListForKey(string):Call(@"email")};
		    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
		    for (CFIndex i = 0; i < ABMultiValueGetCount(emails); i++) {
		    	id<UnoObject> emailRow = @{ForeignList:Of(emailList).NewDictRow():Call()};

		        NSString *label = (__bridge NSString *) ABMultiValueCopyLabelAtIndex(emails, i);
		        NSString *email = (__bridge NSString *) ABMultiValueCopyValueAtIndex(emails, i);
		        @{ForeignDict:Of(emailRow).SetKeyVal(string,string):Call(@"email", email)};
		        @{ForeignDict:Of(emailRow).SetKeyVal(string,string):Call(@"label", label)};
		    }
		    CFRelease(emails);

		    id<UnoObject> phoneList = @{ForeignDict:Of(row).AddListForKey(string):Call(@"phone")};
		    ABMultiValueRef phones = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
		    for (int i=0; i < ABMultiValueGetCount(phones); i++) {
		    	id<UnoObject> phoneRow = @{ForeignList:Of(phoneList).NewDictRow():Call()};

		        NSString *label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phones, i);
		        NSString *phone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, i);
		        @{ForeignDict:Of(phoneRow).SetKeyVal(string,string):Call(@"phone", phone)};
		        @{ForeignDict:Of(phoneRow).SetKeyVal(string,string):Call(@"label", label)};

		    }
		    CFRelease(phones);

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