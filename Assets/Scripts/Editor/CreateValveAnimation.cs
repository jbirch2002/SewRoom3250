using UnityEngine;
using UnityEditor;
using System.IO;

public class CreateValveAnimation : EditorWindow
{
    [MenuItem("Tools/Create Valve Spin Animation")]
    public static void CreateAnimation()
    {
        // Find the valve in the scene
        GameObject valve = GameObject.Find("valve");
        if (valve == null)
        {
            Debug.LogError("Could not find a GameObject named 'valve' in the scene. Please select the valve manually.");
            EditorUtility.DisplayDialog("Error", "Could not find valve GameObject. Please select it in the scene and try again.", "OK");
            return;
        }
        
        // Get the valve handle (child or self)
        Transform valveHandle = valve.transform;
        if (valve.transform.childCount > 0)
        {
            valveHandle = valve.transform.GetChild(0);
        }
        
        // Create Animation component if it doesn't exist
        Animation animationComponent = valve.GetComponent<Animation>();
        if (animationComponent == null)
        {
            animationComponent = valve.AddComponent<Animation>();
        }
        
        // Create the animation clip
        AnimationClip clip = new AnimationClip();
        clip.name = "Spin";
        
        // Set the animation to not loop
        AnimationClipSettings settings = AnimationUtility.GetAnimationClipSettings(clip);
        settings.loopTime = false;
        AnimationUtility.SetAnimationClipSettings(clip, settings);
        
        // Create rotation curve for Z axis (valve wheel rotation)
        // Path to the transform we want to animate
        string path = "";
        if (valveHandle == valve.transform)
        {
            path = "";
        }
        else
        {
            path = AnimationUtility.CalculateTransformPath(valveHandle, valve.transform);
        }
        
        // Create rotation curve
        // We'll animate the localRotation.z (Euler Z)
        // Since we're using localRotation, we need to use a quaternion curve
        // But Unity's Animation system works with Euler angles via localEulerAngles
        
        // Get initial rotation
        Vector3 initialEuler = valveHandle.localEulerAngles;
        float initialZ = initialEuler.z;
        
        // Create keyframes for rotation
        // Frame 0: start at initial rotation
        // Frame 30 (1 second at 30fps): rotate 90 degrees
        Keyframe[] keys = new Keyframe[2];
        keys[0] = new Keyframe(0f, initialZ);
        keys[1] = new Keyframe(1f, initialZ + 90f); // Rotate 90 degrees
        
        // Create animation curve
        AnimationCurve curve = new AnimationCurve(keys);
        curve.preWrapMode = WrapMode.Clamp;
        curve.postWrapMode = WrapMode.Clamp;
        
        // Set the curve to the animation clip
        // We animate localEulerAngles.z
        clip.SetCurve(path, typeof(Transform), "localEulerAngles.z", curve);
        
        // Save the animation clip
        string assetPath = "Assets/Scripts/ValveSpin.anim";
        string directory = Path.GetDirectoryName(assetPath);
        if (!Directory.Exists(directory))
        {
            Directory.CreateDirectory(directory);
        }
        
        AssetDatabase.CreateAsset(clip, assetPath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        
        // Add the clip to the Animation component
        animationComponent.AddClip(clip, "Spin");
        animationComponent.clip = clip;
        
        Debug.Log($"Created animation clip at {assetPath} and added it to the valve's Animation component.");
        EditorUtility.DisplayDialog("Success", $"Created animation clip at {assetPath}\n\nAdded it to the valve's Animation component.", "OK");
        
        // Select the valve in the hierarchy
        Selection.activeGameObject = valve;
    }
}

