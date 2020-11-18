//  Created by Romain Derrien on 18/11/2020.

import SwiftUI
import ARKit

@main
struct scenemeshApp: App {
    var body: some Scene {
        WindowGroup {
          LidarMesh().ignoresSafeArea().statusBar(hidden: true)
        }
    }
}

struct LidarMesh : UIViewRepresentable {

  func makeUIView(context: Context) -> ARSCNView {

    let sceneView = ARSCNView()
    sceneView.autoenablesDefaultLighting = true
    sceneView.delegate = context.coordinator
    let config = ARWorldTrackingConfiguration()
    config.environmentTexturing = .automatic
    config.sceneReconstruction = .mesh
    sceneView.session.run(config)
    return sceneView
  }

  class Coordinator: NSObject, ARSCNViewDelegate {

    let parent : LidarMesh
    init(_ parent: LidarMesh) {
      self.parent = parent
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
      guard let meshAnchor = anchor as? ARMeshAnchor else { return }
      node.geometry = SCNGeometry.makeFromMeshAnchor(meshAnchor)
    }
  }
  func makeCoordinator() -> Coordinator { Coordinator(self) }
  func updateUIView(_ uiView: ARSCNView, context: Context) { }
}

extension SCNMaterial {
  static var gold : SCNMaterial {
    let 🎨 = SCNMaterial()
    🎨.lightingModel = .physicallyBased
    🎨.diffuse.contents = #colorLiteral(red: 0.9351461391, green: 0.884508848, blue: 0.2810415839, alpha: 1)
    🎨.metalness.contents = 1
    🎨.roughness.contents = 0.1
    return 🎨
  }
}
//extension copied from this great UIKit repo https://github.com/apparata/ARKitMeshTest
extension SCNGeometry {

  public static func makeFromMeshAnchor(_ meshAnchor: ARMeshAnchor) -> SCNGeometry {
    let vertices = meshAnchor.geometry.vertices
    let normals = meshAnchor.geometry.normals
    let faces = meshAnchor.geometry.faces

    let vertexSource = SCNGeometrySource(buffer: vertices.buffer,
                                         vertexFormat: vertices.format,
                                         semantic: .vertex,
                                         vertexCount: vertices.count,
                                         dataOffset: vertices.offset,
                                         dataStride: vertices.stride)

    let normalSource = SCNGeometrySource(buffer: normals.buffer,
                                         vertexFormat: normals.format,
                                         semantic: .normal,
                                         vertexCount: normals.count,
                                         dataOffset: normals.offset,
                                         dataStride: normals.stride)

    let uvSource = SCNGeometrySource(buffer: vertices.buffer,
                                     vertexFormat: MTLVertexFormat.float2,
                                     semantic: .texcoord,
                                     vertexCount: vertices.count,
                                     dataOffset: vertices.offset,
                                     dataStride: vertices.stride)

    let triangleData = Data(bytesNoCopy: faces.buffer.contents(),
                            count: faces.buffer.length,
                            deallocator: .none)

    let geometryElement = SCNGeometryElement(data: triangleData,
                                             primitiveType: .triangles,
                                             primitiveCount: faces.count,
                                             bytesPerIndex: faces.bytesPerIndex)

    let sources = [vertexSource, normalSource, uvSource]
    let geometry = SCNGeometry(sources: sources, elements: [geometryElement])
    geometry.firstMaterial = .gold
    return geometry
  }
}

