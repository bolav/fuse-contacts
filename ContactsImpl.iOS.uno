using Uno;
using Uno.Collections;
using Fuse;
using Bolav.ForeignHelpers;
using Uno.Compiler.ExportTargetInterop;

[Require("Source.Import","AddressBook/AddressBook.h")]
[Require("Xcode.Framework", "AddressBook")]
public extern(iOS) class ContactsImpl
{
	public static void GetAllImpl(ListDict ret) 
	@{
		ABAddressBookRef addressBook = ABAddressBookCreate( );
		CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
		CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );

		for ( int i = 0; i < nPeople; i++ )
		{
		    ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
		}
	@} 
}
