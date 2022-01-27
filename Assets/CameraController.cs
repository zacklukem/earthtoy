using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float speed = 500.0f;

    void Update()
    {
        if (Input.GetKey(KeyCode.W)) {
            transform.Translate(transform.forward * Time.deltaTime * speed);
        } else if (Input.GetKey(KeyCode.S)) {
            transform.Translate(-transform.forward * Time.deltaTime * speed);
        }
    }
}
