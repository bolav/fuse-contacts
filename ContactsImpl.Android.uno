using Uno;
using Uno.Collections;
using Fuse;
using Bolav.ForeignHelpers;
using Uno.Threading;
using Uno.Compiler.ExportTargetInterop;

public extern(Android) class ContactsImpl
{
	// http://stackoverflow.com/questions/12562151/android-get-all-contacts
	[Foreign(Language.Java)]
	public static void GetAllImpl(ForeignList ret) 
	@{
		ContentResolver cr = getContentResolver();
		Cursor cur = cr.query(ContactsContract.Contacts.CONTENT_URI,
		        null, null, null, null);

		if (cur.getCount() > 0) {
		    while (cur.moveToNext()) {
		        String id = cur.getString(
		                cur.getColumnIndex(ContactsContract.Contacts._ID));
		        String name = cur.getString(cur.getColumnIndex(
		                ContactsContract.Contacts.DISPLAY_NAME));

		        if (Integer.parseInt(cur.getString(cur.getColumnIndex(
		                    ContactsContract.Contacts.HAS_PHONE_NUMBER))) > 0) {
		            Cursor pCur = cr.query(
		                    ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
		                    null,
		                    ContactsContract.CommonDataKinds.Phone.CONTACT_ID +" = ?",
		                    new String[]{id}, null);
		            while (pCur.moveToNext()) {
		                String phoneNo = pCur.getString(pCur.getColumnIndex(
		                        ContactsContract.CommonDataKinds.Phone.NUMBER));
		                Toast.makeText(NativeContentProvider.this, "Name: " + name 
		                        + ", Phone No: " + phoneNo, Toast.LENGTH_SHORT).show();
		            }
		            pCur.close();
		        }
		    }
		}
	@}

	public static Future<string> AuthorizeImpl()
	{
		var p = new Promise<string>();
		p.Reject(new Exception("Authorize not required on current platform"));
		return p;
	}
}
