using UnityEngine;

namespace com.vhs_screen_effect
{
    [DefaultExecutionOrder(-10000)]
    public class UnscaledShaderTimeDriver : MonoBehaviour
    {
        private static readonly int UnscaledTimeParamsId = Shader.PropertyToID("_UnscaledTimeParams");

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
        private static void AutoCreate()
        {
            if (Object.FindAnyObjectByType<UnscaledShaderTimeDriver>() != null)
                return;

            GameObject go = new GameObject("Unscaled Shader Time Driver");
            DontDestroyOnLoad(go);
            go.AddComponent<UnscaledShaderTimeDriver>();
        }

        private void Update()
        {
            float t = Time.unscaledTime;
            Shader.SetGlobalVector(UnscaledTimeParamsId, new Vector4(t * 0.05f, t, t * 2f, t * 3f));
        }
    }
}