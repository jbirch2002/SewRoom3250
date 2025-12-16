using UnityEngine;

public class Gramophone : MonoBehaviour
{
    public Transform record;
    public float turnSpeed;
    private Vector3 direction = Vector3.up;


    void Update()
    {
        record.Rotate(turnSpeed * direction * Time.deltaTime);
        
    }
}
