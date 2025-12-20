using UnityEngine;
using UnityEditor;
using System.IO;

public class SewerWaterSetupTool : Editor
{
    [MenuItem("Tools/Setup Sewer Water")]
    public static void SetupSewerWater()
    {
        // 1. Get the Water Plane
        GameObject waterPlane = Selection.activeGameObject;
        
        if (waterPlane == null)
        {
            // Try to find by name if nothing selected
            waterPlane = GameObject.Find("WaterPlane");
            if (waterPlane == null) waterPlane = GameObject.Find("Plane");
            
            if (waterPlane == null)
            {
                EditorUtility.DisplayDialog("Setup Error", "Please select the Water Plane object in the Hierarchy first!", "OK");
                return;
            }
        }
        
        Undo.RegisterCompleteObjectUndo(waterPlane, "Setup Sewer Water");

        // 2. Add Manager Script
        SewerRoomWaterManager manager = waterPlane.GetComponent<SewerRoomWaterManager>();
        if (manager == null) manager = Undo.AddComponent<SewerRoomWaterManager>(waterPlane);
        
        // 3. Create Debris Child
        Transform debrisTrans = waterPlane.transform.Find("Debris");
        GameObject debrisObj;
        
        if (debrisTrans == null)
        {
            debrisObj = new GameObject("Debris");
            debrisObj.transform.SetParent(waterPlane.transform, false);
            // Lift debris slightly so it's on surface
            debrisObj.transform.localPosition = new Vector3(0, 0.05f, 0); 
            Undo.RegisterCreatedObjectUndo(debrisObj, "Create Debris");
        }
        else
        {
            debrisObj = debrisTrans.gameObject;
        }

        // 4. Setup Debris Components
        if (debrisObj.GetComponent<ParticleSystem>() == null) Undo.AddComponent<ParticleSystem>(debrisObj);
        if (debrisObj.GetComponent<FloatingDebrisSetup>() == null) Undo.AddComponent<FloatingDebrisSetup>(debrisObj);
        
        manager.debrisParticles = debrisObj.GetComponent<ParticleSystem>();
        manager.waterPlane = waterPlane.transform; // Assign self as water plane
        
        // 5. Connect to Valve
        ValveController valve = Object.FindFirstObjectByType<ValveController>();
        if (valve != null)
        {
            Undo.RecordObject(valve, "Link Valve to Water");
            SerializedObject so = new SerializedObject(valve);
            SerializedProperty prop = so.FindProperty("sewerWaterManager");
            if (prop != null)
            {
                prop.objectReferenceValue = manager;
                so.ApplyModifiedProperties();
                Debug.Log($"Successfully linked {waterPlane.name} to {valve.name}!");
            }
            else
            {
                Debug.LogWarning("Could not find 'sewerWaterManager' field on ValveController. Is it [SerializeField]?");
            }
        }
        
        // 6. Fix Collider (triggers on concave mesh colliders are illegal)
        Collider col = waterPlane.GetComponent<Collider>();
        if (col is MeshCollider)
        {
            Undo.DestroyObjectImmediate(col);
            col = Undo.AddComponent<BoxCollider>(waterPlane);
            ((BoxCollider)col).size = new Vector3(10, 0.1f, 10);
            ((BoxCollider)col).center = new Vector3(0, 0.05f, 0); 
        }
        else if (col == null) 
        {
            col = Undo.AddComponent<BoxCollider>(waterPlane);
            ((BoxCollider)col).size = new Vector3(10, 0.1f, 10);
            ((BoxCollider)col).center = new Vector3(0, 0.1f, 0);
        }
        if (col != null) col.isTrigger = true; 

        // 7. Create and Assign Sewer Material (Visuals)
        CreateAndAssignWaterMaterial(waterPlane);

        // 8. Handle Grate Layer (So particles pass through it)
        bool grateFound = false;
        string[] grateNames = new string[] { "Grate", "grate", "SewerGrate", "sewer_grate", "Sewer Grate" };
        GameObject grateObj = null;

        foreach (string name in grateNames)
        {
            grateObj = GameObject.Find(name);
            if (grateObj != null) break;
        }

        // Search recursively if not found at root
        if (grateObj == null)
        {
            ValveController vc = Object.FindFirstObjectByType<ValveController>();
            if (vc != null)
            {
                // Grate might be near valve?
                Transform t = vc.transform.parent ? vc.transform.parent.Find("Grate") : null;
                if (t != null) grateObj = t.gameObject;
            }
        }

        if (grateObj != null)
        {
            Undo.RecordObject(grateObj, "Set Grate Layer");
            grateObj.layer = 1; // TransparentFX layer (standard Unity layer)
            Debug.Log($"Found Grate '{grateObj.name}' and set to TransparentFX layer.");
            grateFound = true;
        }
        else
        {
            Debug.LogWarning("Could not find an object named 'Grate' or 'SewerGrate'. You must manually set your Grate object's Layer to 'TransparentFX' for debris to flow through it!");
        }

        // 9. Handle Floor Collisions
        bool floorFound = false;
        GameObject floorObj = GameObject.Find("Floor");
        if (floorObj == null) floorObj = GameObject.Find("Floors");
        
        if (floorObj != null)
        {
            // Ensure Floor is NOT transparent
            if (floorObj.layer == 1) 
            {
                floorObj.layer = 0; // Default
                Debug.Log("Fixed: Floor was on TransparentFX layer. Reset to Default.");
            }
            
            // Check for colliders in children
            Collider[] floorCols = floorObj.GetComponentsInChildren<Collider>();
            if (floorCols.Length == 0)
            {
                Debug.LogWarning("Floor object found but has no colliders! Particles will fall through.");
                // Optional: Add MeshColliders? Safer to warn.
            }
            floorFound = true;
        }



        // 10. Audio Setup
        SetupAudio(manager);

        string msg = $"Sewer water updated!\n\n1. Material & Particles applied.\n2. Audio 'rustyvalveturn' & 'sewerwater' assigned.\n3. Water bubbling sound assigned.";
        if (grateFound) msg += "\n4. Grate set to TransparentFX.";
        if (!floorFound) msg += "\n\nWARNING: 'Floor' object not found. Ensure your floor has colliders!";
        
        EditorUtility.DisplayDialog("Success!", msg, "OK");
    }

    private static void SetupAudio(SewerRoomWaterManager manager)
    {
        // 1. Find Clips
        AudioClip valveClip = FindClip("rustyvalveturn");
        AudioClip pipeClip = FindClip("sewerwater");
        AudioClip bubblyClip = FindClip("bubbly");

        // 2. Setup Valve Audio
        ValveController valve = Object.FindFirstObjectByType<ValveController>();
        if (valve != null)
        {
            Undo.RecordObject(valve, "Setup Valve Audio");
            
            // A. Turn Sound (Always on Valve)
            AudioSource turnSource = GetOrCreateAudioSource(valve.gameObject, "Audio_Turn");
            Configure3DAudioSource(turnSource, valveClip, false, 1.0f);
            
            // B. Pipe Flow Sound (MUST be on the WaterFlow object, not Valve)
            SerializedObject so = new SerializedObject(valve);
            SerializedProperty waterFlowProp = so.FindProperty("waterFlow");
            GameObject pipeSoundTarget = null;
            
            // Clean up potentially wrongly placed audio on the valve itself
            Transform oldPipeSound = valve.transform.Find("Audio_PipeFlow");
            if (oldPipeSound != null)
            {
                Undo.DestroyObjectImmediate(oldPipeSound.gameObject);
                Debug.Log("Removed misplaced pipe sound from Valve.");
            }
            
            if (waterFlowProp != null && waterFlowProp.objectReferenceValue != null)
            {
                pipeSoundTarget = ((Component)waterFlowProp.objectReferenceValue).gameObject;
                Debug.Log($"Attaching pipe sound to WaterFlow Object: {pipeSoundTarget.name}");
            }
            
            if (pipeSoundTarget == null)
            {
                pipeSoundTarget = valve.gameObject; // Fallback
                Debug.LogWarning("WaterFlow object not assigned! Pipe sound will play from Valve (which might be wrong).");
            }

            // Create source on the correct target
            AudioSource pipeSource = GetOrCreateAudioSource(pipeSoundTarget, "Audio_PipeFlow");
            Configure3DAudioSource(pipeSource, pipeClip, true, 1.0f);

            // Assign references
            SetProperty(so, "valveTurnSource", turnSource);
            SetProperty(so, "pipeWaterSource", pipeSource);
            so.ApplyModifiedProperties();
        }

        // 3. Setup Rising Water Audio (On the Room Water Plane)
        if (manager != null)
        {
            Undo.RecordObject(manager, "Setup Water Audio");
            AudioSource riseSource = GetOrCreateAudioSource(manager.gameObject, "Audio_RisingBubbles");
            Configure3DAudioSource(riseSource, bubblyClip, true, 1.0f);
            
            manager.risingWaterSound = riseSource;
        }
    }

    private static void SetProperty(SerializedObject so, string propertyName, Object value)
    {
        SerializedProperty prop = so.FindProperty(propertyName);
        if (prop != null) prop.objectReferenceValue = value;
    }

    private static AudioSource GetOrCreateAudioSource(GameObject parent, string childName)
    {
        Transform t = parent.transform.Find(childName);
        GameObject obj;
        if (t == null)
        {
            obj = new GameObject(childName);
            obj.transform.SetParent(parent.transform, false);
            Undo.RegisterCreatedObjectUndo(obj, "Create Audio Source");
        }
        else
        {
            obj = t.gameObject;
        }
        
        AudioSource source = obj.GetComponent<AudioSource>();
        if (source == null) source = Undo.AddComponent<AudioSource>(obj);
        return source;
    }

    private static void Configure3DAudioSource(AudioSource source, AudioClip clip, bool loop, float pitch)
    {
        source.clip = clip;
        source.loop = loop;
        source.playOnAwake = false;
        source.spatialBlend = 1.0f; // 3D Sound
        source.dopplerLevel = 0f; // No doppler for stationary objects
        source.rolloffMode = AudioRolloffMode.Logarithmic;
        source.minDistance = 2f;
        source.maxDistance = 15f;
        source.pitch = pitch;
    }

    private static AudioClip FindClip(string namePart)
    {
        string[] guids = AssetDatabase.FindAssets(namePart + " t:AudioClip");
        if (guids.Length > 0)
        {
            string path = AssetDatabase.GUIDToAssetPath(guids[0]);
            return AssetDatabase.LoadAssetAtPath<AudioClip>(path);
        }
        return null;
    }

    private static void CreateAndAssignWaterMaterial(GameObject waterPlane)
    {
        Renderer rend = waterPlane.GetComponent<Renderer>();
        if (rend == null) return;

        // Check if we already have a generated material
        string matPath = "Assets/Materials/SewerWater_Generated.mat";
        Material waterMat = AssetDatabase.LoadAssetAtPath<Material>(matPath);

        if (waterMat == null)
        {
            // Create a decent sewer water material
            waterMat = new Material(Shader.Find("Standard"));
            waterMat.name = "SewerWater_Generated";
            
            // Murky Green/Brown
            waterMat.SetColor("_Color", new Color(0.15f, 0.2f, 0.05f, 0.85f)); 
            
            // Transparent Setup for Standard Shader
            waterMat.SetFloat("_Mode", 3); // Transparent
            waterMat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
            waterMat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
            waterMat.SetInt("_ZWrite", 0);
            waterMat.DisableKeyword("_ALPHATEST_ON");
            waterMat.EnableKeyword("_ALPHABLEND_ON");
            waterMat.DisableKeyword("_ALPHAPREMULTIPLY_ON");
            waterMat.renderQueue = 3000;
            
            // Glossy/Wet
            waterMat.SetFloat("_Glossiness", 0.9f);
            waterMat.SetFloat("_Metallic", 0.2f); // Slight metallic shimmy for oil/slime

            // Ensure directory exists
            if (!Directory.Exists("Assets/Materials")) Directory.CreateDirectory("Assets/Materials");
            
            AssetDatabase.CreateAsset(waterMat, matPath);
            Debug.Log("Created new Sewer Water material.");
        }

        // Allow undoing material change
        Undo.RecordObject(rend, "Assign Water Material");
        rend.sharedMaterial = waterMat;
    }
    [MenuItem("Tools/Setup Sewer Lighting (Dank & Dark)")]
    public static void SetupSewerLighting()
    {
        // 0. CLEAR BAKED DATA FIRST
        // If the user has baked data, changing settings won't visibly update until they rebake OR clear.
        // We force clear so they see the result immediately.
        LightmapSettings.lightmaps = new LightmapData[0];
        Debug.Log("Auto-cleared old baked data to show new lighting settings.");

        // 1. Ambient Light (Increased visibility)
        Undo.RecordObject(GetRenderSettings(), "Setup Dank Lighting");
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
        // Much brighter base ambient (Dark Grey-Green instead of Pitch Black)
        // R:0.15, G:0.2, B:0.15 ensures colors are visible but still 'sewer-like'
        RenderSettings.ambientLight = new Color(0.15f, 0.2f, 0.15f); 
        RenderSettings.ambientIntensity = 1.0f; 

        // 2. Fog (The "Dankness")
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.ExponentialSquared;
        RenderSettings.fogDensity = 0.02f; // Reduced density so you can see further
        RenderSettings.fogColor = new Color(0.1f, 0.15f, 0.1f); // Brighter fog

        // 3. Lights - Handle Directional and Point lights
        Light[] lights = Object.FindObjectsByType<Light>(FindObjectsSortMode.None);
        foreach (Light l in lights)
        {
            Undo.RecordObject(l, "Dank Lighting Adjustment");
            
            if (l.type == LightType.Directional)
            {
                // Pale moonlight - Boosted Intensity
                l.color = new Color(0.6f, 0.7f, 0.65f); 
                l.intensity = 0.5f; // Increased from 0.05 to 0.5 (10x brighter)
                l.shadows = LightShadows.Soft;
            }
            else if (l.type == LightType.Point)
            {
                // Make point lights moody and localized
                // Allow brighter lights now
                if (l.intensity > 5.0f) l.intensity = 3.0f; // Cap at 3 instead of 1
                
                // Ensure they cast shadows for atmosphere
                l.shadows = LightShadows.Soft; 
                
                // Reduce range to create pools of light rather than global illumination
                if (l.range > 15f) l.range = 12f; 
                
                Debug.Log($"Adjusted Point Light '{l.name}' for atmosphere.");
            }
        }
        
        // 4. Reflections - Brighten them back up so metals pop
        RenderSettings.defaultReflectionMode = UnityEngine.Rendering.DefaultReflectionMode.Custom;
        RenderSettings.reflectionIntensity = 0.5f; // Restored visibility

        EditorUtility.DisplayDialog("Lighting Updated", 
            "Sewer atmosphere applied (Balanced)!\n\n" +
            "- Ambient: Visible Dark Green\n" +
            "- Fog: Thinner\n" +
            "- Sun: Brighter Moonlight\n" +
            "- Baked Data: CLEARED (Use 'Generate Lighting' if you want to bake this)\n\n" +
            "You should see the changes immediately now.", "OK");
    }

    [MenuItem("Tools/Clear Baked Lighting")]
    public static void ClearBakedData()
    {
        // LightmapSettings.lightmaps = new LightmapData[0] effectively clears baked data at runtime/editor
        LightmapSettings.lightmaps = new LightmapData[0];
        Debug.Log("Baked lighting data cleared from scene.");
        EditorUtility.DisplayDialog("Cleared", "Baked lighting removed. You are back to Realtime preview.", "OK");
    }

    private static Object GetRenderSettings()
    {
        return null; // Undo for RenderSettings is tricky, usually handled by scene state.
    }
    [MenuItem("Tools/Export Sewer Package")]
    public static void ExportSewerPackage()
    {
        string exportPath = "SewerRoomAsset.unitypackage";
        
        // List of specific assets/folders to export
        // We include dependencies to ensure materials/textures come along
        string[] assetPaths = new string[] 
        {
            "Assets/SewerRoomScene.unity", // The Scene itself
            "Assets/SewerRoom.prefab",    // The Room Prefab
            "Assets/SewerRoom",           // Models folder
            "Assets/Materials/SewerWater_Generated.mat",
            "Assets/Scripts/SewerRoomWaterManager.cs",
            "Assets/Scripts/ValveController.cs", 
            "Assets/Scripts/FloatingDebrisSetup.cs",
            "Assets/Scripts/WaterParticleSetup.cs",
            "Assets/Scripts/Editor/SewerWaterSetupTool.cs", // Include the tool itself for easy setup in new project!
            "Assets/Audio/rustyvalveturn.mp3",
            "Assets/Audio/sewerwater.mp3",
            "Assets/Audio/bubbly.mp3"
        };
        
        Debug.Log("Exporting Sewer Room Package...");
        
        // Check for missing files just in case
        System.Collections.Generic.List<string> validPaths = new System.Collections.Generic.List<string>();
        foreach (var path in assetPaths)
        {
            if (AssetDatabase.IsValidFolder(path) || System.IO.File.Exists(path))
            {
                validPaths.Add(path);
            }
            else
            {
                Debug.LogWarning($"Skipping missing asset for export: {path}");
            }
        }

        AssetDatabase.ExportPackage(validPaths.ToArray(), exportPath, ExportPackageOptions.Recurse | ExportPackageOptions.IncludeDependencies);
        
        Debug.Log($"Export Complete! Saved to: {System.IO.Path.GetFullPath(exportPath)}");
        EditorUtility.RevealInFinder(exportPath);
    }
}
