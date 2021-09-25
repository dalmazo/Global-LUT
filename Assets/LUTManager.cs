using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class LUTManager : MonoBehaviour
{
    public Texture2D LutDefault;

    public static LUTManager Instance;

    private float influence=0;
    private Queue<LUTStep> LUTQueue;

    private void OnEnable()
    {
        if(Instance == null)
        {
            Instance = this;
            name = "LUT Manager";
        }
        else
        {
            Destroy(gameObject);
        }

        LUTQueue = new Queue<LUTStep>();

        print("Reseting LUT");
        OnDisable();
    }

    private void OnDisable()
    {
        Shader.SetGlobalFloat("_Contribution", 1);
        Shader.SetGlobalFloat("_LUTAtoB", 0);
        Shader.SetGlobalTexture("_LUTA", LutDefault);
    }

    public void ToLUT(LUTStep lutstep, bool toQueue = true)
    {
        StartCoroutine(toLUT(lutstep, toQueue));
    }

    private IEnumerator toLUT(LUTStep lutstep, bool toQueue = true)
    {
        if(!toQueue) //force now, kill all queue and do it now
        {
            if (queueManagerRunning != null)
            {
                StopCoroutine(queueManagerRunning);
                queueManagerRunning = null;
            }

            LUTQueue.Clear();
        }

        LUTQueue.Enqueue(lutstep);
        print($"Adding 1 to queue | | {LUTQueue.Count} queued");
        
        if(queueManagerRunning == null)
        {
            queueManagerRunning = queueManager();
            StartCoroutine(queueManagerRunning);
        }

        yield return null;
    }

    private IEnumerator queueManagerRunning;
    private IEnumerator queueManager()
    {
        while(LUTQueue.Count > 0)
        {
            LUTStep step = LUTQueue.Dequeue();

            if(influence > 0.5f) // To 0 (A)
            {
                print($"Going next lut: {step.LUT.name} | {LUTQueue.Count} queued");
                Shader.SetGlobalTexture("_LUTA", step.LUT);
                Shader.SetGlobalFloat("_Contribution", step.Contribution);

                while (influence > 0)
                {
                    influence = Mathf.Clamp(influence - Time.fixedDeltaTime, 0, 1);
                    yield return new WaitForSeconds(Time.fixedDeltaTime);
                    Shader.SetGlobalFloat("_LUTAtoB", influence);
                }
                print($"Lut ended.");
            }
            else // To 1 (B)
            {
                print($"Going next lut: {step.LUT.name} | {LUTQueue.Count} queued");
                Shader.SetGlobalTexture("_LUTB", step.LUT);
                Shader.SetGlobalFloat("_Contribution", step.Contribution);

                while (influence < 1)
                {
                    influence = Mathf.Clamp(influence + Time.fixedDeltaTime, 0, 1);
                    yield return new WaitForSeconds(Time.fixedDeltaTime);
                    Shader.SetGlobalFloat("_LUTAtoB", influence);
                }
                print($"Lut ended.");
            }
            yield return null;
        }
        print($"Killing lut running");
        queueManagerRunning = null;
    }
}

public struct LUTStep
{
    public Texture2D LUT;
    public float Time;
    public float Contribution;
}
