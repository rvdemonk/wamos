
import voidImg from '../images/void.jpeg'
import wolfImg from '../images/wolf.jpeg'
import stoneImg from '../images/stone.jpeg'
import oceanImg from '../images/ocean.jpeg'
import sunImg from '../images/sun.jpeg'
import treeImg from '../images/tree.jpeg'
import mountainImg from '../images/mountain.jpeg'
import heartImg from '../images/heart.jpeg'


export function Loading() {

  const v0id = ["The V0id g0d abides...", "loading-image void", voidImg]
  const w0lf = ["The w0lf g0d hides...", "loading-image wolf", wolfImg]
  const st0ne = ["The St0ne g0d waits...", "loading-image stone", stoneImg]
  const ocean = ["The 0cean g0d stirs...", "loading-image ocean", oceanImg]
  const sun = ["The Sun g0d falls...", "loading-image sun", sunImg]
  const tree = ["The Tree g0d grows...", "loading-image tree", treeImg]
  const m0untain = ["The M0untain g0d shakes...", "loading-image mountain", mountainImg]
  const heart = ["The heart g0d breaks...", "loading-image heart", heartImg]


  const g0ds = [v0id, w0lf, st0ne, ocean, sun, tree, m0untain, heart]

  function choose(choices) {
    var index = Math.floor(Math.random() * choices.length);
    return choices[index];
  }

  const loadGod = choose(g0ds)

  return (

    <div className='article'>
      <div className ="loading">
        <img src = {loadGod[2]} className={loadGod[1]} width="500px" height = "500px"></img>

      </div>
   
    </div>
  );
}
