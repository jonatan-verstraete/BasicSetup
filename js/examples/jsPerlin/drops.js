const drops = []
let dropamt = 3000
const gridDetail = 50
const grid = []
let gloablColor = 0


const noiseSetup = {
    df: 500,
    zoff: 1,
    scale: 1,
    inc() {
        this.zoff += 0.002
    }
}
/**
 * Explenation for not curious enough people about the argument in the "All" Class.
 If you don't take your steps in life (All Class) your purpose in life will be lost.
 If you curve in a system (Grid Class) you will look for even more system and stability.
 If you want to live like a drop you experiance a short but colourfull life (like the Drop Class object being removed from the memory when it reaches 10px under the screen)
 */

class All {
    constructor(yourPurposeInLife = "lost"){
        this.purposeInLife = yourPurposeInLife

    }
    getNoise(x, y, strength=1) {
        const {df, zoff, scale:noiseScale} = noiseSetup
        let value = noise.perlin3(x/df,  y/df,  zoff)
            
        const angle = ((1 + value) * 1.1 * 128) / (PI * 2)
        return rotateVector(x * noiseScale*strength, y*noiseScale*strength, angle)

    }
}

class Grid extends All {
    constructor() {
        super("be in balance")
        this.points = []
        for(let x of range(Xmax)) {
            for(let y of range(Ymax)) {
                if(x%gridDetail==0 && y%gridDetail==0) this.points.push({x:x, y:y})
            }
        }
    }
    draw() {
        for(let p of this.points) {
            const {x, y} = p
            const v = this.getNoise(x, y,2)
            line(x, y, x+v.x, y+v.y, "#666")
        }
    }
}


class Drop extends All {
    constructor() {
        super("to flower in life")
        this.speed = (randint(10) + 0.1)/20
        this.x = randint(Xmax)
        this.y = -20

        this.initx=this.x
        this.inity=this.y


        this.width = this.speed * 10
        this.color = 0
    }
    reset(){
        this.x = randint(Xmax)
        this.y = -20
        this.color = 0
    }
    draw() {
        const {x, y, width} = this
        this.y += this.speed

        if(y>Ymax+10) this.reset()
        const v = this.getNoise(x, y, this.speed)

        circle(x+v.x, y+v.y, width, hsl(this.color+gloablColor))
        this.color += 0.1
    }
}


 
async function main() {
    ctx.invert()
    // see: https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Compositing
    ctx.globalCompositeOperation = "screen"
    ctx.globalAlpha = 1
    const grid = new Grid()


    let iter=0
    async function animation() {
        iter++
        //rect(0, 0, Xmax, Ymax, null, "#ffffff08")
        if(iter%8===0){
            ctx.globalCompositeOperation = "source-over"
            rect(0, 0, Xmax, Ymax, null, "#00000001")
            ctx.globalCompositeOperation = "screen"
            ctx.globalAlpha = 1
        }


        if(drops.length<dropamt)  drops.push(new Drop())
        // grid.draw()

        for(let i of drops) i.draw()


        noiseSetup.inc()
        gloablColor = overcount(gloablColor+.1, 360)

        await pauseHalt()
       if(!exit) requestAnimationFrame(animation)
    }
    animation()
}

main()