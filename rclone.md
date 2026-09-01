Install as a binary and do NOT use RPM layers
GUI applications       → Flatpak
CLI applications       → Homebrew
Development environments → Distrobox
Base operating system  → Immutable


```bash
brew install rclone
```

Ensure it did install

```bash
rclone version
```

Your Google Account
↓
Your Google OAuth Client
↓
rclone
↓
~/GoogleDrive
↓
Dolphin




Step 1 — Create the Google Cloud project

Go to:

Google Cloud Console

Sign in using the Google account whose Drive you want to mount.

At the top, click the project selector and choose:

New Project

I'd name it something obvious like:

rclone - Aurora Laptop

Create it and make sure that project is selected.

Step 2 — Enable Google Drive API

Open:

Google Drive API in Google Cloud Console

Make sure your new project is selected at the top.

Click:

Enable

Step 3 — Stop there




## Switch to tab api 

Click “Configure consent screen” — the button in the yellow bar near the middle-right.

Google should then take you into the OAuth configuration. You'll likely be asked for:

App name: rclone - Aurora Laptop
User support email: your Google email
Audience: we'll choose this based on whether this is a personal Gmail account or your Google Workspace account.
Developer/contact email: your email

Go ahead and click Configure consent screen and show me the next screen. We'll go one screen at a time because Google's current interface differs from a lot of the rclone tutorials online.





## Switch to data access tab

Because your goal is to use rclone as a normal Google Drive filesystem — browse existing files, drag new files in, edit, rename and delete — we need full Drive access. The narrower drive.file permission isn't sufficient because it only lets rclone access files that rclone itself created.

Click Add or remove scopes.

In the window that opens, scroll down until you see Manually add scopes. According to rclone's current setup instructions, add these three:

https://www.googleapis.com/auth/docs
https://www.googleapis.com/auth/drive
https://www.googleapis.com/auth/drive.metadata.readonly

You may be able to paste them together comma-separated:




## switch to Clients tab


Yes. Now click “Create client.” ✅

On the next screen:

Application type: Desktop app
Name: something like rclone - Aurora Yoga

Then click Create.

Google should give you two important values:

Client ID
Client Secret

Don't paste those here — treat the Client Secret as a credential.

Once you have that screen, keep it open. Next we'll run:

rclone config




Enter:

n

and press Enter.

It will ask:

name>

I'd use:

gdrive

So you'll have a nice simple remote name:

gdrive:

After that, rclone will show you a long numbered list of storage providers and ask for Storage>.

Choose Google Drive. The number can vary by rclone version, so look for the line resembling:

Google Drive
\ (drive)

Enter its number (or drive if your prompt says you can enter a value directly).

Then stop when you reach:

client_id>

That's where we're going to enter the Client ID you just created in Google Cloud. Don't send the Client ID or Secret to me.








Choose 1 — Full access.

Enter:

1

and press Enter.

That's what you want for your use case because you're trying to make the mounted Google Drive behave like a normal filesystem:

browse → open → create → drag files in → edit → rename → move → delete

Option 3 (drive.file) sounds attractive from a security standpoint, but it would only give rclone access to files it created itself, which would defeat your goal of browsing and managing your existing Drive.

So:

scope> 1

Send me the next question rclone asks and we'll keep going one prompt at a time.








Leave this blank and press Enter.

service_account_file>

We're using your personal OAuth login with the Client ID + Client Secret you created, not a Google Service Account.

So just:

Enter ↵

Then send me the next prompt.









ok i was able to authenticate and confirm

2026/09/01 13:46:50 NOTICE: Got code
Configure this as a Shared Drive (Team Drive)?

y) Yes
n) No (default)
y/n>



Great — authentication worked. ✅

Choose:

n

and press Enter.

A Shared Drive is the Google Workspace feature where the files belong to the organization/team rather than an individual's My Drive.

You're connecting your normal Google Drive, so:

Configure this as a Shared Drive (Team Drive)?
n

After that, rclone should show you a summary of the new gdrive remote and ask whether you want to keep it.

Send me that next screen and we'll verify it before saving.

keep this "gdrive" remote?
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
y/e/d>



Yes — choose:

y

and press Enter. ✅

That saves your gdrive remote.

After it returns to the main rclone configuration menu, choose:

q

to quit.

Then let's do a read-only test first before mounting anything:

rclone lsd gdrive:

That should list the folders in the root of your Google Drive.

This command doesn't change or upload anything; it just confirms rclone can successfully read your Drive.








rclone mount gdrive: ~/GoogleDrive   --vfs-cache-mode full   --vfs-cache-max-size 20G   --vfs-cache-max-age 24h

fusermount3 -u ~/GoogleDrive




## setup to run in background

ENSURE YOU STOP RUNNING

```shell
which rclone
```

Ensure fuse is closed

```shell
fusermount3 -u ~/GoogleDrive
# Ensure nothing stale remains
fusermount3 -u ~/GoogleDrive 2>/dev/null || true
```

### Create systemd service

```shell
mkdir -p ~/.config/systemd/user
nano ~/.config/systemd/user/rclone-gdrive.service
```

Paste this into the file 
- IMPORTANT swap {{USERNAME}} with your username on linux
```shell
[Unit]
Description=Google Drive rclone mount
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
ExecStartPre=/usr/bin/mkdir -p /var/home/{{USERNAME}}/GoogleDrive
ExecStart=/usr/bin/rclone mount gdrive: /var/home/{{USERNAME}}/GoogleDrive \
    --config=/var/home/{{USERNAME}}/.config/rclone/rclone.conf \
    --cache-dir=/var/home/{{USERNAME}}/.cache/rclone \
    --vfs-cache-mode=full \
    --vfs-cache-max-size=20G \
    --vfs-cache-max-age=24h
ExecStop=/usr/bin/fusermount3 -u /var/home/{{USERNAME}}/GoogleDrive
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target

```

4. Tell systemd about the new service
```shell
systemctl --user daemon-reload
```

Then enable it for future logins and start it now:

```shell
systemctl --user enable --now rclone-gdrive.service
```

Check running
```shell
systemctl --user status rclone-gdrive.service
```






The important lines are:

Loaded: ... enabled
Active: active (running)

and:

to upload 0, uploading 0

So your setup is now:

Aurora login
↓
systemd user service
↓
rclone starts automatically
↓
Google Drive mounts at ~/GoogleDrive
↓
Dolphin can use it normally

The preset: disabled part is not a problem. Your service itself is explicitly enabled, which is what matters.

Also, this status line is useful:

vfs cache: objects 744 ... total size 4.903Gi





