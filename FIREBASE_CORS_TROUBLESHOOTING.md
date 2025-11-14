# Troubleshooting Firebase Storage CORS - Bucket Not Found

## Step 1: Find Your Actual Bucket Name

The bucket name might be different from what we expected. Let's find it:

### Option A: Check in Google Cloud Console
1. Go to: https://console.cloud.google.com/storage/browser?project=fureverhealthy-admin
2. Look at the list of buckets - note the exact name

### Option B: List buckets using gcloud
Run this in Cloud Shell:
```bash
gsutil ls
```

This will show all buckets in your project.

### Option C: Check Firebase Console
1. Go to: https://console.firebase.google.com/project/fureverhealthy-admin/storage
2. The bucket name is shown at the top of the Storage page

## Step 2: Common Bucket Names

Firebase Storage buckets can have different formats:
- `fureverhealthy-admin.appspot.com` (default)
- `fureverhealthy-admin.firebasestorage.app` (newer format)
- `gs://fureverhealthy-admin.appspot.com`
- A custom bucket name you might have created

## Step 3: Create the Bucket if It Doesn't Exist

If the bucket doesn't exist, you need to create it first:

### Method 1: Create via Firebase Console
1. Go to: https://console.firebase.google.com/project/fureverhealthy-admin/storage
2. Click "Get Started" if Storage isn't initialized
3. This will create the default bucket

### Method 2: Create via gcloud
```bash
# Create the bucket
gsutil mb -p fureverhealthy-admin gs://fureverhealthy-admin.appspot.com

# Or if using the newer format:
gsutil mb -p fureverhealthy-admin gs://fureverhealthy-admin.firebasestorage.app
```

## Step 4: Apply CORS to the Correct Bucket

Once you know the correct bucket name, apply CORS:

```bash
# Replace BUCKET_NAME with the actual bucket name you found
gsutil cors set cors.json gs://BUCKET_NAME
```

## Step 5: Verify Storage is Enabled

Make sure Firebase Storage is enabled:
1. Go to: https://console.firebase.google.com/project/fureverhealthy-admin/storage
2. If you see "Get Started", click it to enable Storage
3. This will create the default bucket automatically

