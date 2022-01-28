using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour {
    public float speed = 0.00001f;
    public float bobSpeed = 0.0001f;
    public float bobAmplitude = 20.0f;
    public float bobOffset = 120.0f;
    public float lookOffset = 2.0f;
    public float lookDown = 1.0f;

    void Update() {
        float height = bobAmplitude * Mathf.Sin(Time.time * bobSpeed) + bobOffset;
        transform.position =
            height * new Vector3(0, Mathf.Sin(Time.time * speed), Mathf.Cos(Time.time * speed));
        transform.LookAt(
            (height
             * new Vector3(
                 0,
                 Mathf.Sin(Time.time * speed + lookOffset),
                 Mathf.Cos(Time.time * speed + lookOffset)))
                - transform.position.normalized * lookDown,
            transform.position.normalized);
    }
}
