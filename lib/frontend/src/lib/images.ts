export function unsplash(id: string, width = 1200, quality = 75) {
  return `https://images.unsplash.com/photo-${id}?auto=format&fit=crop&w=${width}&q=${quality}`;
}

export const images = {
  hero: unsplash("1782528013685-812fbcd20085", 1800, 80),
  about: unsplash("1700912679829-bd525d1724a8", 1000),
  customMade: unsplash("1673201229733-69d19c5c4a87", 900),
  readyToWear: unsplash("1596783074918-c84cb06531ca", 900),
  preLoved: unsplash("1445205170230-053b83016050", 900),
  howItWorks: unsplash("1517840545241-b491010a8af4", 1200),
  designers: unsplash("1552162864-987ac51d1177", 1000),
  global: unsplash("1760907949889-eb62b7fd9f75", 1000),
  fabricTexture: unsplash("1768212565424-efa3a3852b81", 1800, 60),
};
