using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LUTConsumer : MonoBehaviour
{

    public Texture2D[] LUTs;
    int i = 0;

    public void Next()
    {
        if (i >= LUTs.Length)
        {
            i = 0;
        }
        LUTStep step = new LUTStep { LUT = LUTs[i], Contribution = 1, Time = 2f };
        i++;
        LUTManager.Instance.ToLUT(step);
    }
    public void NextForced()
    {
        if (i >= LUTs.Length)
        {
            i = 0;
        }
        LUTStep step = new LUTStep { LUT = LUTs[i], Contribution = 1, Time = 2f };
        i++;
        LUTManager.Instance.ToLUT(step, false);
    }
}
