## Oracle DB Configuration

In order for the fully managed Oracle CDC Connector V1 to properly work with the Oracle DB provisioned via Terraform in AWS certain, Oracle DB settings must be configured.

The Oracle DB is configured on a private network within AWS, making it inaccessible from your local machine, and only accessibile from a machine within the private network.

This machine existing within the AWS private network has already been setup by Terraform and can be accessed using `Windows App` application that we downloaded in the [prerequisite software section](#4-windows-jump-server-software-installation).

<details>
<summary>Access Windows Machine in Internal Network</summary>

1. Open the `Windows App`![windows_app_view.png](img/windows_app_view.png)
2. Click the `+` Icon to add new Server Connection, Click `Add PC` from the dropdown menu
3. Enter `windows_instance_ip` value from Terraform outputs in the `PC name:` textbox
4. Click the `Credentials` dropdown menu, select `Add Credentials...`, A pop up menu will appear
5. Enter `windows_instance_username` value from Terraform outputs into the `Username:` text field
6. Enter `windows_instance_password` value from Terraform outputs into the `Password:` text field
7. Click the `Add` button in the bottom right of the credentials pop up 
8. Click the `Add` button in the bottom right of the instance pop up
9. Click the newly created pop up titled with the `windows_instance_ip`
10. You will be redirected to a Windows OS for the machine located the AWS Oracle DB network
</details>

<details>
<summary>Download Oracle DB Client Software on Internal Windows Machine</summary>

1. Open the web browser on the machine
2. Download your Database Tool of Choice (I prefer Pycharm) **Note:** Pycharm will automatically download Oracle JDK
3. Download Oracle JDK 
4. Open your DB tool
5. Connect to the DB 
</details>

<details>
<summary>Configure Oracle DB on Internal Windows machine</summary>

1. Run the following command to configure the Database

   ```oracdle
   begin
    rdsadmin.rdsadmin_util.alter_supplemental_logging(
        p_action => 'ADD',
        p_type   => 'ALL');
   end;
   ```
2. Validate the database is configured
   ```oracle
   SELECT log_mode FROM v$database;
   ```
   
   **Expected Output:**
   ```text
   LOG_MODE
   -------
   ARCHIVELOG
   ```
3. The database has now been configured.

**Note:** Minimize the window to the Internal Windows Machine it will be used later (you can always connect again if you already closed it)
</details>

---