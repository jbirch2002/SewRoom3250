using UnityEngine;

public class Phone : MonoBehaviour
{
    private Material mat;
    private MeshRenderer rend;

    public float activationDistance = 10;


    private void OnEnable()
    {
        FPController.InFocusAtDistance += ActivatePhoneScreen;     
    }

    private void OnDisable()
    {
        FPController.InFocusAtDistance -= ActivatePhoneScreen;
    }

    void Start()
    {
        rend = GetComponent<MeshRenderer>();
        mat = rend.material;

        
    }

    void Update()
    {
        
    }

    void ActivatePhoneScreen(GameObject go, float dist)
    {
        if (go != gameObject)
        { 
            if (mat.IsKeywordEnabled("_EMISSION")) mat.DisableKeyword("_EMISSION");
            return;
        }


        if (dist <= activationDistance)
        {
            if (!mat.IsKeywordEnabled("_EMISSION")) mat.EnableKeyword("_EMISSION");
        }



    }
}
