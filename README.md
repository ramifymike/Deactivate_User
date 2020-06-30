# Deactivate_User

To handle user off-boarding of the user lifecycle process. The script will first backup key attributes of the account. The settings are Distribution Group Membership, Account Settings, and Office 365 Licenses. It will then remove the group assignments, remove the license of the account in Office 365, move the account to a specific Organizational Unit, and modify the description with a note stating the Administrator who made the change, on what date, and a ticket number.
