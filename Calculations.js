// DATA FOR NODES GOES BELOW
const nodeData = [
    {
        x:0,
        y:0,
        forceExternalX: 594.486,
        forceExternalY: 0,
        externalForceType: 'roller'
    },
    {
        x:0.3,
        y:0,
        forceExternalX: 0,
        forceExternalY: -99.081,
        externalForceType: 'load'
    },
    {
        x:0,
        y:0.05,
        forceExternalX: -594.486,
        forceExternalY: 99.081,
        externalForceType: 'pin'
    },
    {
        x:0.2,
        y:0,
        forceExternalX: 0,
        forceExternalY: 0,
        externalForceType: null
    },
    {
        x:0.25,
        y:0.05,
        forceExternalX: 0,
        forceExternalY: 0,
        externalForceType: null
    },
    {
        x:0.1,
        y:0.05,
        forceExternalX: 0,
        forceExternalY: 0,
        externalForceType: null
    }
];

// DATA FOR MEMBERS GO BELOW

const members = [
    {
        node1: 0,
        node2: 2,
        force: 99.081,
        zIndex: 0
    },
    {
        node1: 0,
        node2: 3,
        force: -396.324,
        zIndex: 2
    },
    {
        node1: 4,
        node2: 3,
        force: -140.122,
        zIndex: 1
    },
    {
        node1: 4,
        node2: 1,
        force: 140.122,
        zIndex: 0
    },
    {
        node1: 1,
        node2: 3,
        force: -99.081,
        zIndex: 3
    },
    {
        node1: 5,
        node2: 0,
        force: -221.552,
        zIndex: 1
    },
    {
        node1: 5,
        node2: 3,
        force: 221.552,
        zIndex: 0
    },
    {
        node1: 2,
        node2: 5,
        force: 594.486,
        zIndex: 2
    },
    {
        node1: 5,
        node2: 4,
        force: 198.162,
        zIndex: 3
    }
];

function length(node1, node2){
    return (
        Math.sqrt(Math.pow((node2.x-node1.x), 2) + Math.pow((node2.y-node1.y), 2))
    );
}
nodeArray = [];

function getConnectedNodes(nodeNum){
    const connectedNodes = [];
    for(let i = 0; i < members.length; i++){
        if(nodeNum === members[i].node1){
            connectedNodes.push({
                nodeNum: members[i].node2,
                x: nodeData[members[i].node2].x,
                y: nodeData[members[i].node2].y,
                forceExternalX: nodeData[members[i].node2].forceExternalX,
                forceExternalY: nodeData[members[i].node2].forceExternalY,
                memberForce: members[i].force,
                zIndex: members[i].zIndex
            })
        }
        if(nodeNum === members[i].node2){
            connectedNodes.push({
                nodeNum: members[i].node1,
                x: nodeData[members[i].node1].x,
                y: nodeData[members[i].node1].y,
                forceExternalX: nodeData[members[i].node1].forceExternalX,
                forceExternalY: nodeData[members[i].node1].forceExternalY,
                memberForce: members[i].force,
                zIndex: members[i].zIndex
            })
        }
    }
    return connectedNodes;
}

// FUNCTION TO GET FORCES ON A SINGLE NODE

function getForces(nodeNum){
    const connectedNodes = getConnectedNodes(nodeNum);
    const forcesFromEachMember = [];
    for(let i = 0; i< connectedNodes.length; i++){
        const forceX = connectedNodes[i].memberForce*(connectedNodes[i].x- nodeData[nodeNum].x)/length(nodeData[nodeNum], connectedNodes[i]);
        const forceY = connectedNodes[i].memberForce*(connectedNodes[i].y- nodeData[nodeNum].y)/length(nodeData[nodeNum], connectedNodes[i]);
        forcesFromEachMember.push({
            fromNode: connectedNodes[i].nodeNum,
            forceX: forceX,
            forceY: forceY,
            zIndex: connectedNodes[i].zIndex
        });
    }

    forcesFromEachMember.push({
        fromNode: nodeNum,
        forceX: nodeData[nodeNum].forceExternalX,
        forceY: nodeData[nodeNum].forceExternalY,
        zIndex: null
    });

    return forcesFromEachMember;
}

// FUCNTION TO GET REQUIRED DOWEL LENGTH FOR A NODE BELOW

function getDowelLength(nodeNum){
    const connectedNodes = getConnectedNodes(nodeNum);
    const zIndiceis = connectedNodes.map(node => node.zIndex);
    return Math.max(...zIndiceis) + 1;
}

// FUNCTION TO GET MAX SHEAR ON A SINGLE DOWEL(NODE)

function getMaxShear(nodeNum){
    const forces = getForces(nodeNum);
    const forcesXByZIndex = [];
    const forcesYByZIndex = [];
    forcesXByZIndex.length = getDowelLength(nodeNum) - 1;
    forcesYByZIndex.length = forcesXByZIndex.length;
    forcesXByZIndex.fill(0);
    forcesYByZIndex.fill(0);
    for(let i = 0; i < forces.length-1; i++){
        forcesXByZIndex[forces[i].zIndex] = forces[i].forceX;
        forcesYByZIndex[forces[i].zIndex] = forces[i].forceY;
    }
    const shearXByZIndex = [];
    const shearYByZIndex = [];
    for(let i = 0; i < forcesXByZIndex.length; i++){
        let shearX = nodeData[nodeNum].forceExternalX/2, shearY = nodeData[nodeNum].forceExternalY/2;
        for(let j = 0; j < i; j++){
            shearX += forcesXByZIndex[j];
            shearY += forcesYByZIndex[j];
        }
        shearXByZIndex.push(shearX);
        shearYByZIndex.push(shearY);
    }
    const shearMagnitudeByZIndex = [];
    for(let i = 0; i < shearYByZIndex.length; i++){
        shearMagnitudeByZIndex.push(Math.sqrt(Math.pow(shearXByZIndex[i], 2) + Math.pow(shearYByZIndex[i], 2)));
    }
    return Math.max(...shearMagnitudeByZIndex) > Math.abs(Math.min(...shearMagnitudeByZIndex)) ? Math.max(...shearMagnitudeByZIndex) : Math.min(...shearMagnitudeByZIndex);
}

// CONSTANTS
// member thickness in mm 
const memberThickness = 1.5875;
// dowel area in m^2
const dowelArea = Math.PI * (361/160000)**2;

// FUNCTION TO GET MAX MOMENT ON A SINGLE DOWEL(NODE)

function getMaxMoment(nodeNum){
    const forces = getForces(nodeNum);
    const forcesXByZIndex = [];
    const forcesYByZIndex = [];
    forcesXByZIndex.length = getDowelLength(nodeNum) - 1;
    forcesYByZIndex.length = forcesXByZIndex.length;
    forcesXByZIndex.fill(0);
    forcesYByZIndex.fill(0);
    for(let i = 0; i < forces.length-1; i++){
        forcesXByZIndex[forces[i].zIndex] = forces[i].forceX;
        forcesYByZIndex[forces[i].zIndex] = forces[i].forceY;
    }
    const shearXByZIndex = [];
    const shearYByZIndex = [];
    for(let i = 0; i < forcesXByZIndex.length; i++){
        let shearX = nodeData[nodeNum].forceExternalX/2, shearY = nodeData[nodeNum].forceExternalY/2;
        for(let j = 0; j < i; j++){
            shearX += forcesXByZIndex[j];
            shearY += forcesYByZIndex[j];
        }
        shearXByZIndex.push(shearX);
        shearYByZIndex.push(shearY);
    }
    const momentXByZIndex = [];
    const momentYByZIndex = [];
    for(let i = 0; i < shearXByZIndex.length; i++){
        let momentX = 0, momentY = 0;
        for(let j = 0; j < i; j++){
            momentX += shearXByZIndex[j];
            momentY += shearYByZIndex[j];
        }
        momentXByZIndex.push(momentX);
        momentYByZIndex.push(momentY);
    }
    const momentMagnitudeByZIndex = [];
    for(let i = 0; i < momentYByZIndex.length; i++){
        momentMagnitudeByZIndex.push(Math.sqrt(Math.pow(momentXByZIndex[i], 2) + Math.pow(momentYByZIndex[i], 2)));
    }
    return Math.max(...momentMagnitudeByZIndex) > Math.abs(Math.min(...momentMagnitudeByZIndex)) ? Math.max(...momentMagnitudeByZIndex)*memberThickness : Math.min(...momentMagnitudeByZIndex)*memberThickness;
}
function findMemberAngles(){
    const memberAngles = [];
    for(let i = 0; i < members.length; i++){
        const deltaY = nodeData[members[i].node2].y - nodeData[members[i].node1].y;
        const deltaX = nodeData[members[i].node2].x - nodeData[members[i].node1].x;
        if(Math.atan(deltaY/deltaX)*180/Math.PI > 0)
            memberAngles.push(Math.atan(deltaY/deltaX)*180/Math.PI);
        else if(deltaY === 0){
            memberAngles.push(0);
        }
        else if(deltaX === 0){
            memberAngles.push(90);
        }
        else{
            memberAngles.push(180 + Math.atan(deltaY/deltaX)*180/Math.PI);
        }
    }
    return memberAngles;
}

// EXAMPLES FOR FUNCTION EXECUTION
// console.log(getForces(0));
// console.log(getDowelLength(0));
// console.log(getMaxShear(0));
// console.log(getMaxMoment(0));

function findAll(){
    let dowelLength = 0;
    for(let i = 0; i < nodeData.length; i++){
        console.log("max shear force on node " + i + " is: " + getMaxShear(i) + " N");
        console.log("max moment on node " + i + " is: " + getMaxMoment(i) + " Nxmm");
        console.log("max shear stress on node " + i + " is: " + (getMaxShear(i)/dowelArea)/(10**6) + " MPa")
        dowelLength += getDowelLength(i);
    }
    console.log("total dowel length: " + dowelLength*memberThickness + " mm");
    console.log("total dowel mass: " + (dowelLength*memberThickness/10)*dowelArea*10000*0.747 + " g");
    console.log(findMemberAngles());
}


findAll();