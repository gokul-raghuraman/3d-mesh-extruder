class LoopManager
{
  ArrayList<Loop> loops;
  LoopNode rootLoop;
  Mesh mesh;
  
  LoopManager(ArrayList<Loop> l, Mesh m)
  {
    loops = new ArrayList <Loop>();
    for (int i = 0; i < l.size(); i++)
    {
      loops.add(l.get(i));
    }
    mesh = m;
    
    //Build the containment tree
    makeLoopTree();
  }
  
  ArrayList<Integer[]> getBridgeVertices(int extrudeSection)
  {
    ArrayList<LoopNode> children = rootLoop.getChildren();
    ArrayList<Integer[]> vertexPairs = new ArrayList<Integer[]>();

    if (extrudeSection == 0)
    {
      Loop rootLoop = children.get(0).loop;
      for (int i = 1; i < children.size(); i++)
      {
        Loop queryLoop = children.get(i).loop;
        
        Vertex vQuery = queryLoop.vertices.get(0);
        Vertex vRoot = rootLoop.vertices.get(0);
        
        int vQueryIndex = queryLoop.vIndices.get(0);
        int vRootIndex = rootLoop.vIndices.get(0);
        
        float minDist = pow(vQuery.x - vRoot.x, 2) + pow(vQuery.y - vRoot.y, 2);
        for (int k = 0; k < rootLoop.vertices.size(); k++)
        {
          Vertex v = rootLoop.vertices.get(k);
          float dist = pow(vQuery.x - v.x, 2) + pow(vQuery.y - v.y, 2);
          if (dist < minDist)
          {
            vRoot = v;
            minDist = dist;
            vRootIndex = rootLoop.vIndices.get(k);
          }
        }
        vertexPairs.add(new Integer[]{vQueryIndex, vRootIndex});
      }
      
    }
    
    else if (extrudeSection == 1)
    {
      Loop outerLoop = rootLoop.loop;
      for (int i = 0; i < children.size(); i++)
      {
        Loop innerLoop = children.get(i).loop;
        Vertex vInner = innerLoop.vertices.get(0);
        Vertex vOuter = outerLoop.vertices.get(0);  
        int vInnerIndex = innerLoop.vIndices.get(0);
        int vOuterIndex = outerLoop.vIndices.get(0);   
        float minDist = pow(vInner.x - vOuter.x, 2) + pow(vInner.y - vOuter.y, 2);
        for (int k = 0; k < outerLoop.vertices.size(); k++)
        {
          Vertex v = outerLoop.vertices.get(k);
          float dist = pow(vInner.x - v.x, 2) + pow(vInner.y - v.y, 2);
          if (dist < minDist)
          {
            vOuter = v;
            minDist = dist; 
            vOuterIndex = outerLoop.vIndices.get(k);
          }
        }
        vertexPairs.add(new Integer[]{vInnerIndex, vOuterIndex});
      }
    }
    return vertexPairs;
  }
  
  int getNumLoops()
  {
    return loops.size();
  }
  
  int getOuterLoopCorner()
  {
    int cIndex = 0;
    if (!pointInternal(mesh.getCornerPos2d(cIndex, 5), loops.get(0)))
    {
      cIndex = mesh.S.get(cIndex);
    }
    return cIndex;
  }
  
  int getInnerLoopCorner()
  {
    Loop childLoop = rootLoop.getChildren().get(0).loop;
    int cIndex = mesh.getCornerFromVertex(childLoop.vStart);
    if (pointInternal(mesh.getCornerPos2d(cIndex, 5), childLoop))
    {
      cIndex = mesh.S.get(cIndex);
    } 
    
    return cIndex;
    
  }

  void makeLoopTree()
  {
    //Sort loops based on area
    for (int i = 0; i < loops.size() - 1; i++)
    {
      for (int j = 0; j < loops.size() - i - 1; j++)
      {
        if (loops.get(j).getArea() < loops.get(j + 1).getArea())
        {
          Loop swapLoop = new Loop(loops.get(j));
          loops.set(j, new Loop(loops.get(j + 1)));
          loops.set(j + 1, new Loop(swapLoop));
        }
      }
    }
    
    rootLoop = new LoopNode(loops.get(0));
    Loop queryLoop = rootLoop.loop;
    for (int i = 0; i < loops.size(); i++)
    {
      if (loopInternal(loops.get(i), queryLoop))
      {
        rootLoop.addChild(new LoopNode(loops.get(i)));
      }
    }
  }
  
  void traverse(LoopNode node)
  {
    if (node.children.size() == 0)
    {
      return;
    }
    for (int i = 0; i < node.children.size(); i++)
    {
      traverse(node.children.get(i));
    }
  }
  
  boolean pointInternal(Vertex p, Loop loop)
  {
    int numIntersections = 0;
    for (int i = 0; i < loop.vertices.size() - 1; i++)
    {
      Vertex a = loop.vertices.get(i);
      Vertex b = loop.vertices.get(i + 1);
      numIntersections += rayCast(p, a, b);
    }
    numIntersections += rayCast(p, loop.vertices.get(loop.vertices.size() - 1), loop.vertices.get(0));
    
    if (numIntersections % 2 == 1)
      return true;

    return false;
  }
  
  boolean loopInternal(Loop loopA, Loop loopB)
  {
    //returns true if loopA inside loopB
    Vertex p = loopA.vertices.get(0);
    return pointInternal(p, loopB);
  }


}
class LoopNode
{
  Loop loop;
  
  LoopNode parent;
  ArrayList<LoopNode> children;
  
  LoopNode(Loop l)
  {
    children = new ArrayList<LoopNode>();
    setData(l);
  }
  
  LoopNode()
  {
    children = new ArrayList<LoopNode>();
  }
  
  void setData(Loop l)
  {
    loop = new Loop(l);
  }
  
  void addChild(LoopNode c)
  {
    children.add(new LoopNode(c.loop));
  }
  
  void removeChild(LoopNode c)
  {
    for (int i = 0; i < children.size(); i++)
    {
      if (children.get(i).loop.vStart == c.loop.vStart)
      {
        children.remove(i);
        break;
      }
    }
  }
  
  ArrayList<LoopNode> getChildren()
  {
    return children;
  }
  
  LoopNode getParent()
  {
    return parent;
  }
}

class Loop
{
  int vStart;
  ArrayList<Vertex> vertices;
  ArrayList<Integer> vIndices;
  Loop(int v, ArrayList<Integer> vInd, ArrayList<Vertex> verts)
  {
    vStart = v;
    vertices = new ArrayList<Vertex>();
    vIndices = new ArrayList<Integer>();

    for (int i = 0; i < verts.size(); i++)
    {
      vertices.add(verts.get(i));
    }
    
    for (int i = 0; i < vInd.size(); i++)
    {
      vIndices.add(vInd.get(i));
    }
    
  }
  
  Loop(Loop l)
  {
    vStart = l.vStart;
    vertices = new ArrayList<Vertex>();
    vIndices = new ArrayList<Integer>();
    
    for (int i = 0; i < l.vertices.size(); i++)
    {
      vertices.add(l.vertices.get(i));
    }
    
    for (int i = 0; i < l.vIndices.size(); i++)
    {
      vIndices.add(l.vIndices.get(i));
    }
  }
  
  float getArea()
  {
    float area = 0.0;
    
    Vertex first = vertices.get(0);
    Vertex last = vertices.get(vertices.size() - 1);
    
    for (int i = 0; i < vertices.size() - 1; i++)
    {
      Vertex cur = vertices.get(i);
      Vertex next = vertices.get(i + 1);
      area += cur.x * next.y - cur.y * next.x;
    }
    area += last.x * first.y - last.y * first.x;
    area /= 2.0;
    return abs(area); 
  }
}

