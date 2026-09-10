using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Pool;

namespace Day10
{
    public class ClickEffectSpawner : MonoBehaviour
    {
        [SerializeField] private Camera targetCamera;
        [SerializeField] private ParticleSystem effectPrefab;
        [SerializeField] private LayerMask groundMask;

        private Vector2 pointerPosition;
        private ObjectPool<ParticleSystem> effectPool;

        private void Awake()
        {
            effectPool = new ObjectPool<ParticleSystem>(
                createFunc: () =>
                {
                    ParticleSystem effect = Instantiate(effectPrefab);
                    ParticleSystem.MainModule main = effect.main;
                    main.stopAction = ParticleSystemStopAction.Callback;

                    if (!effect.TryGetComponent(out ParticleSystemHandler returnEffect))
                    {
                        returnEffect = effect.gameObject.AddComponent<ParticleSystemHandler>();
                    }

                    returnEffect.OnEffectStopped += () => effectPool.Release(effect);

                    return effect;
                },
                actionOnGet: effect => effect.gameObject.SetActive(true),
                actionOnRelease: effect =>
                {
                    effect.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
                    effect.gameObject.SetActive(false);
                },
                actionOnDestroy: effect => Destroy(effect.gameObject),
                collectionCheck: false,
                defaultCapacity: 10,
                maxSize: 20
            );
        }

        public void OnPoint(InputValue value) => pointerPosition = value.Get<Vector2>();

        public void OnClick(InputValue value)
        {
            if (!value.isPressed)
            {
                return;
            }

            Ray ray = targetCamera.ScreenPointToRay(pointerPosition);
            if (Physics.Raycast(ray, out RaycastHit hit, targetCamera.farClipPlane, groundMask))
            {
                ParticleSystem effect = effectPool.Get();
                effect.transform.SetPositionAndRotation(hit.point, Quaternion.LookRotation(hit.normal));
                effect.Play(true);
            }
        }
    }
}