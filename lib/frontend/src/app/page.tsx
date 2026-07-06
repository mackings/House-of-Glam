import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import TrustStrip from "@/components/TrustStrip";
import About from "@/components/About";
import Offerings from "@/components/Offerings";
import HowItWorks from "@/components/HowItWorks";
import Protection from "@/components/Protection";
import ForDesigners from "@/components/ForDesigners";
import GlobalReach from "@/components/GlobalReach";
import CTA from "@/components/CTA";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <>
      <Navbar />
      <main>
        <Hero />
        <TrustStrip />
        <About />
        <Offerings />
        <HowItWorks />
        <Protection />
        <ForDesigners />
        <GlobalReach />
        <CTA />
      </main>
      <Footer />
    </>
  );
}
