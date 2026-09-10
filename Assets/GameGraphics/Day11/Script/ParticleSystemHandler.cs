using System;
using UnityEngine;

namespace Day10
{
    public class ParticleSystemHandler : MonoBehaviour
    {
        public event Action OnEffectStopped;

        private void OnParticleSystemStopped() => OnEffectStopped?.Invoke();
    }
}