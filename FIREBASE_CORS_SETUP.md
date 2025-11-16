# Firebase Storage CORS Configuration

This guide explains how to configure CORS (Cross-Origin Resource Sharing) for Firebase Storage to allow images to load in your Flutter web app.

## Why CORS is Needed

When running a Flutter web app, the browser enforces CORS policies. If Firebase Storage doesn't have proper CORS configuration, images from Firebase Storage will fail to load with CORS errors.

## Method 1: Using Google Cloud Console (Recommended)

### Step 1: Install Google Cloud SDK (if not already installed)

1. Download and install Google Cloud SDK from: https://cloud.google.com/sdk/docs/install
2. Or use the web-based Cloud Shell: https://console.cloud.google.com/cloudshell

### Step 2: Authenticate with Google Cloud

```bash
gcloud auth login
```

### Step 3: Set your project

```bash
gcloud config set project fureverhealthy-admin
```

### Step 4: Create CORS configuration file

Create a file named `cors.json` with the following content:

```json
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Content-Length", "Authorization"]
  }
]
```

**Note:** Using `"origin": ["*"]` allows all origins. For production, you should specify your actual domain(s):

```json
[
  {
    "origin": [
      "https://your-domain.com",
      "https://www.your-domain.com",
      "https://your-site.netlify.app",
      "http://localhost:5000",
      "http://localhost:8080"
    ],
    "method": ["GET", "HEAD"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Content-Length", "Authorization"]
  }
]
```

### Important: For Netlify Deployment

When deploying to Netlify, you **must** update your CORS configuration to include your Netlify domain. After deploying to Netlify, you'll get a URL like `https://your-site-name.netlify.app`. 

1. Update your `cors.json` file to include your Netlify domain:
```json
[
  {
    "origin": [
      "https://your-site-name.netlify.app",
      "https://your-site-name.netlify.app/*",
      "http://localhost:5000",
      "http://localhost:8080"
    ],
    "method": ["GET", "HEAD"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Content-Length", "Authorization"]
  }
]
```

2. Apply the updated CORS configuration:
```bash
gsutil cors set cors.json gs://fureverhealthy-admin.appspot.com
```

3. If you have a custom domain on Netlify, also add that domain to the CORS configuration.

### Step 5: Apply CORS configuration

```bash
gsutil cors set cors.json gs://fureverhealthy-admin.appspot.com
```

### Step 6: Verify CORS configuration

```bash
gsutil cors get gs://fureverhealthy-admin.appspot.com
```

## Method 2: Using Firebase Console (Alternative)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `fureverhealthy-admin`
3. Go to **Storage** in the left sidebar
4. Click on the **Rules** tab
5. However, note that CORS cannot be configured directly in Firebase Console - you must use gsutil (Method 1)

## Method 3: Using Google Cloud Console Web UI

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `fureverhealthy-admin`
3. Navigate to **Cloud Storage** > **Buckets**
4. Click on your bucket: `fureverhealthy-admin.appspot.com`
5. Go to the **Configuration** tab
6. Scroll down to **CORS configuration**
7. Click **Edit CORS configuration**
8. Paste the JSON configuration from the `cors.json` file
9. Click **Save**

## Troubleshooting

### If you get "Permission denied" error:

Make sure you have the necessary permissions:
- Storage Admin role, or
- Storage Object Admin role

### If images still don't load after CORS configuration:

1. **Clear browser cache** - CORS settings are cached
2. **Check browser console** - Look for CORS errors
3. **Verify the configuration** - Run `gsutil cors get gs://fureverhealthy-admin.appspot.com`
4. **Check the URL format** - Make sure the image URLs are properly formatted

### Common CORS Error Messages:

- `Access to XMLHttpRequest has been blocked by CORS policy` - CORS not configured
- `No 'Access-Control-Allow-Origin' header` - CORS configuration missing or incorrect
- `Preflight request doesn't pass` - CORS configuration doesn't allow the request method

## Testing CORS Configuration

After configuring CORS, test by:

1. Opening your Flutter web app
2. Opening browser DevTools (F12)
3. Going to the Network tab
4. Trying to load an image
5. Checking if there are any CORS errors in the Console tab

## Security Note

For production, **do not use `"origin": ["*"]`. Instead, specify your actual domains:

```json
[
  {
    "origin": [
      "https://fureverhealthy-admin.web.app",
      "https://fureverhealthy-admin.firebaseapp.com",
      "https://your-site-name.netlify.app",
      "https://your-custom-domain.com"
    ],
    "method": ["GET", "HEAD"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Content-Length", "Authorization"]
  }
]
```

This prevents unauthorized websites from accessing your Firebase Storage resources.

## Netlify Deployment Checklist

Before deploying to Netlify, ensure:

1. ✅ **CORS Configuration Updated**: Add your Netlify domain to Firebase Storage CORS settings
2. ✅ **netlify.toml Created**: Configuration file is in the project root
3. ✅ **Firebase Config**: Your Firebase configuration in `lib/config/firebase_config.dart` is correct
4. ✅ **Build Test**: Test the build locally with `flutter build web --release`

After deployment:
- Verify your app loads correctly on Netlify
- Check browser console for any CORS errors
- Test Firebase authentication and storage functionality

