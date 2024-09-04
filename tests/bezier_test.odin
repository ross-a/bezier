/* [[file:../../../blender.org::*Bezier Curve][Bezier Curve:1]] */
package bezier_test



import "core:fmt"
import "core:mem"
import "vendor:raylib"
import bezier "../"

main :: proc() {
  using raylib
  using bezier

  ta := mem.Tracking_Allocator{};
  mem.tracking_allocator_init(&ta, context.allocator);
  context.allocator = mem.tracking_allocator(&ta);

  {
    WIDTH  :: 500
    HEIGHT :: 500

    InitWindow(WIDTH, HEIGHT, "Bezier")
    SetTargetFPS(60)

    with_raylib := false
    s := [2]f32{10, 20}
    h1 := [2]f32{20, 20}
    e := [2]f32{60, 80}
    e2 := [2]f32{180, 50}
    h2 := [2]f32{70, 100}
    h3 := [2]f32{75, 110}

    bez1 := Bezier{s, e, h1, ZERO, Bezier_Type.QUADRATIC}
    bez2 := Bezier{e, e2, h2, h3, Bezier_Type.CUBIC}
    thick : f32 = 1.0
    color := WHITE

    bezs := []Bezier{bez1, bez2}
    divs := []int{10, 10}
    lut := get_lut_from_many(bezs, divs); defer delete(lut)

    b : []Bez = { Bez{-2,0,1,0,4,0},
                  Bez{7,3,10,3,13,3},
                  Bez{16,0,20,0,23,0} }
    lut2 := get_lut_from_many(b); defer delete(lut2)
    fmt.println(lut2)

    fmt.println(get_value_from_many(b, 9))
    fmt.println(get_value_from_many(b, 20))

    for !WindowShouldClose() {
      // Update ------------------------------
      if IsKeyPressed(raylib.KeyboardKey.SPACE) {
        with_raylib = !with_raylib
      }

      // Draw   ------------------------------
      BeginDrawing()
      ClearBackground(BLACK)

      if with_raylib {
        pt_cnt := 3
        pts := make([^]Vector2, pt_cnt); defer free(pts)
        pts[0] = Vector2{s[0], s[1]}
        pts[2] = Vector2{e[0], e[1]}
        pts[1] = Vector2{h1[0], h1[1]}
        DrawSplineBezierQuadratic(pts, i32(pt_cnt), thick, color)
        pts[0] = Vector2{e[0], e[1]}
        pts[2] = Vector2{e2[0], e2[1]}
        pts[1] = Vector2{h2[0], h2[1]}
        DrawSplineBezierQuadratic(pts, i32(pt_cnt), thick, color)
      } else {
        for i in 0..<len(lut)-1 {
          DrawLineEx(Vector2{lut[i][0], lut[i][1]}, Vector2{lut[i+1][0], lut[i+1][1]}, thick, color)
        }
      }

      EndDrawing()
    }
    CloseWindow()
  }

  if len(ta.allocation_map) > 0 {
    for _, v in ta.allocation_map {
      fmt.printf("Leaked %v bytes @ %v\n", v.size, v.location)
    }
  }
  if len(ta.bad_free_array) > 0 {
    fmt.println("Bad frees:")
    for v in ta.bad_free_array {
      fmt.println(v)
    }
  }
}
/* Bezier Curve:1 ends here */
