import { useRef } from "react";
import "../app.css";
import ScrollToTop from "./ScrollToTop";

export function LandingPage() {
  const services = useRef(null);
  const blog = useRef(null);
  const contact = useRef(null);

  const scrollToSection = (elementRef) => {
    window.scrollTo({
      top: elementRef.current.offsetTop,
      behavior: "smooth",
    });
  };

  return (
    <div className="App">
      <ScrollToTop />
      <div className="hero">
        <div className="hero-grid">
          <div className="item" onClick={() => scrollToSection(services)}>
            Wam0s
          </div>
          <div className="item" onClick={() => scrollToSection(blog)}>
            The Battle Arena
          </div>
          <div className="item" onClick={() => scrollToSection(contact)}>
            About 3Rigby
          </div>
        </div>
      </div>
      <div ref={services} className="services">
        Services
      </div>
      <div ref={blog} className="blog">
        Blog
      </div>
      <div ref={contact} className="contact">
        Contact
      </div>
    </div>
  );
}
