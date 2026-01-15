// Lightweight scroll reveal using IntersectionObserver
(function(){
  if ('IntersectionObserver' in window) {
    const obs = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    }, { root: null, rootMargin: '0px 0px -10% 0px', threshold: 0.08 });

    document.querySelectorAll('.reveal, .reveal-left, .reveal-right').forEach(el=>{
      obs.observe(el);
    });
  } else {
    // fallback: make all visible
    document.querySelectorAll('.reveal, .reveal-left, .reveal-right').forEach(el=> el.classList.add('is-visible'));
  }

  // Simple tilt for pointer movement (optional): add listener only if device supports hover
  if (window.matchMedia('(hover: hover)').matches) {
    document.querySelectorAll('.tilt').forEach(card => {
      card.addEventListener('mousemove', (e)=>{
        const rect = card.getBoundingClientRect();
        const x = (e.clientX - rect.left) / rect.width - 0.5; // -0.5..0.5
        const y = (e.clientY - rect.top) / rect.height - 0.5;
        const rotX = (y * 6).toFixed(2);
        const rotY = (x * -6).toFixed(2);
        card.style.transform = `perspective(800px) rotateX(${rotX}deg) rotateY(${rotY}deg)`;
      });
      card.addEventListener('mouseleave', ()=>{ card.style.transform = ''; });
    });
  }

})();
