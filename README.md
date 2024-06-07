# RandomPW
A random password generator for multiple AD users at once
___________________________________________________________________________________



- The script will prompt the user to identify a CSV file and changes the passwords for all users found within the specified input CSV file.
   
- All changed passwords will be checked by the script to ensure the new password set correctly (credit to mike f. robbins at mikefrobbins.com for the checking function)

- The must contain a column named 'SamAccountName' that contains valid AD account names to receive a new random password



Use cases include:
- New hire accounts that await first contact from IT
- securing compromised AD accounts (accounts should likely also be disabled in this scenario)
- securing AD accounts that must remain enabled but should not be leveraged by the employee
- Script can also be easily modified to write a more uniform initial password for new hires rather than a random password or to output the random passwords for first-use assignment
- Red team pen testing
