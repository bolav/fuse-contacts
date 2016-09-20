using Uno;
using Uno.Collections;
using Fuse;
using Bolav.ForeignHelpers;
using Uno.Threading;
using Uno.Compiler.ExportTargetInterop;
using Android.Base;

[ForeignInclude(Language.Java,
                "android.provider.ContactsContract",
                "android.content.ContentResolver",
                "android.app.Activity",
                "android.database.Cursor")]
public extern(Android) class ContactsImpl
{
	// http://stackoverflow.com/questions/12562151/android-get-all-contacts
	[Foreign(Language.Java)]
	public static void GetAllImpl(ForeignList ret) 
	@{
		Activity a = com.fuse.Activity.getRootActivity();
		ContentResolver cr = a.getContentResolver();
		String selection =  ContactsContract.Contacts.IN_VISIBLE_GROUP + " = ?";
		String[] Args = { "1" };
		Cursor cur = cr.query(ContactsContract.Contacts.CONTENT_URI,
		        null, selection, Args, null);

		if (cur.getCount() > 0) {
		    while (cur.moveToNext()) {
		    	Object row = @{ForeignList:Of(ret).NewDictRow():Call()};

		    	String id = cur.getString(
		    	                cur.getColumnIndex(ContactsContract.Contacts._ID));

		    	@{ForeignDict:Of(row).SetKeyVal(string,string):Call("id", id)};
		    	@{ForeignDict:Of(row).SetKeyVal(string,string):Call("name",
		    		cur.getString(cur.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME)) )};

		    	// read the phone numbers at the current cursor
		        if (Integer.parseInt(cur.getString(cur.getColumnIndex(
		                    ContactsContract.Contacts.HAS_PHONE_NUMBER))) > 0) {
		            Cursor pCur = cr.query(
		                    ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
		                    null,
		                    ContactsContract.CommonDataKinds.Phone.CONTACT_ID +" = ?",
		                    new String[]{id}, null);

		            Object phoneList = @{ForeignDict:Of(row).AddListForKey(string):Call("phone")};
		            while (pCur.moveToNext()) {
		            	Object phoneRow = @{ForeignList:Of(phoneList).NewDictRow():Call()};
		            	@{ForeignDict:Of(phoneRow).SetKeyVal(string,string):Call("phone", 
		            		pCur.getString(pCur.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER))
		            		)};

		            }
		            pCur.close();
		        }

		    	// read the e-mail addresses at the current cursor
				Cursor emailCur = cr.query( 
			 				ContactsContract.CommonDataKinds.Email.CONTENT_URI, 
			 				null,
			 				ContactsContract.CommonDataKinds.Email.CONTACT_ID + " = ?", 
			 				new String[]{id}, null);
				Object emailList = @{ForeignDict:Of(row).AddListForKey(string):Call("email")};
		 		while (emailCur.moveToNext()) { 
	            	Object emailRow = @{ForeignList:Of(emailList).NewDictRow():Call()};
	            	@{ForeignDict:Of(emailRow).SetKeyVal(string,string):Call("email", 
	            		emailCur.getString(emailCur.getColumnIndex(ContactsContract.CommonDataKinds.Email.DATA))
	            		)};
		 		} 
		 		emailCur.close();
		    }
		}
		cur.close();
	@}

	public static Future<string> AuthorizeImpl()
	{
		var p = new Promise<string>();
		Permissions.RequestPermission(Permissions.READ_CONTACTS);

		p.Resolve("AuthorizationAuthorized");
		// p.Reject(new Exception("Authorize not required on current platform"));
		return p;
	}
}
