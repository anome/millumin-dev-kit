{
	"patcher" : 	{
		"fileversion" : 1,
		"appversion" : 		{
			"major" : 5,
			"minor" : 1,
			"revision" : 9
		}
,
		"rect" : [ 625.0, 154.0, 569.0, 396.0 ],
		"bglocked" : 0,
		"defrect" : [ 625.0, 154.0, 569.0, 396.0 ],
		"openrect" : [ 0.0, 0.0, 0.0, 0.0 ],
		"openinpresentation" : 0,
		"default_fontsize" : 12.0,
		"default_fontface" : 0,
		"default_fontname" : "Arial",
		"gridonopen" : 0,
		"gridsize" : [ 15.0, 15.0 ],
		"gridsnaponopen" : 0,
		"toolbarvisible" : 1,
		"boxanimatetime" : 200,
		"imprint" : 0,
		"enablehscroll" : 1,
		"enablevscroll" : 1,
		"devicewidth" : 0.0,
		"boxes" : [ 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "audio input",
					"patching_rect" : [ 362.0, 135.0, 99.0, 23.0 ],
					"fontface" : 1,
					"fontsize" : 14.0,
					"id" : "obj-55",
					"numinlets" : 1,
					"fontname" : "Arial",
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "send OSC",
					"patching_rect" : [ 208.0, 280.0, 92.0, 23.0 ],
					"fontface" : 1,
					"fontsize" : 14.0,
					"id" : "obj-52",
					"numinlets" : 1,
					"fontname" : "Arial",
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "receive OSC",
					"patching_rect" : [ 193.0, 76.0, 102.0, 23.0 ],
					"fontface" : 1,
					"fontsize" : 14.0,
					"id" : "obj-51",
					"numinlets" : 1,
					"fontname" : "Arial",
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "opacity (current layer)",
					"patching_rect" : [ 163.0, 197.0, 126.0, 20.0 ],
					"fontsize" : 12.0,
					"id" : "obj-45",
					"numinlets" : 1,
					"fontname" : "Arial",
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "AUDIO INPUT >> MILLUMIN OPACITY via OSC",
					"patching_rect" : [ 54.0, 22.0, 364.0, 25.0 ],
					"fontface" : 1,
					"fontsize" : 16.0,
					"id" : "obj-42",
					"numinlets" : 1,
					"fontname" : "Arial",
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "multislider",
					"outlettype" : [ "", "" ],
					"patching_rect" : [ 61.0, 168.0, 229.0, 26.0 ],
					"id" : "obj-1",
					"setstyle" : 1,
					"orientation" : 0,
					"numinlets" : 1,
					"setminmax" : [ 0.0, 100.0 ],
					"numoutlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "ezadc~",
					"offgradcolor1" : [ 0.082353, 0.815686, 0.0, 1.0 ],
					"ongradcolor1" : [ 1.0, 0.0, 0.0, 1.0 ],
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 337.0, 67.0, 45.0, 45.0 ],
					"id" : "obj-46",
					"ongradcolor2" : [ 1.0, 0.0, 0.0, 1.0 ],
					"offgradcolor2" : [ 0.290196, 0.72549, 0.0, 1.0 ],
					"bgcolor" : [ 0.643137, 0.643137, 0.643137, 1.0 ],
					"numinlets" : 1,
					"numoutlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "scale 0. 1. 0 100",
					"outlettype" : [ "" ],
					"patching_rect" : [ 316.0, 324.0, 99.0, 20.0 ],
					"fontsize" : 12.0,
					"id" : "obj-17",
					"numinlets" : 6,
					"fontname" : "Arial",
					"numoutlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "meter~",
					"outlettype" : [ "float" ],
					"patching_rect" : [ 337.0, 133.0, 20.0, 143.0 ],
					"id" : "obj-11",
					"numinlets" : 1,
					"numoutlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "START / STOP",
					"patching_rect" : [ 390.0, 68.0, 152.0, 20.0 ],
					"fontface" : 1,
					"fontsize" : 12.0,
					"id" : "obj-6",
					"numinlets" : 1,
					"fontname" : "Arial",
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "route /millumin/layer/opacity/0",
					"outlettype" : [ "", "" ],
					"patching_rect" : [ 61.0, 102.0, 169.0, 20.0 ],
					"fontsize" : 12.0,
					"id" : "obj-83",
					"numinlets" : 1,
					"fontname" : "Arial",
					"numoutlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "udpreceive 5001",
					"outlettype" : [ "" ],
					"patching_rect" : [ 61.0, 77.0, 99.0, 20.0 ],
					"fontsize" : 12.0,
					"id" : "obj-54",
					"numinlets" : 1,
					"fontname" : "Arial",
					"numoutlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "/millumin/layer/opacity/0 $1",
					"outlettype" : [ "" ],
					"patching_rect" : [ 61.0, 255.0, 155.0, 18.0 ],
					"fontsize" : 12.0,
					"id" : "obj-78",
					"numinlets" : 2,
					"fontname" : "Arial",
					"numoutlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "udpsend localhost 5000",
					"patching_rect" : [ 61.0, 280.0, 137.0, 20.0 ],
					"fontsize" : 12.0,
					"id" : "obj-15",
					"numinlets" : 1,
					"fontname" : "Arial",
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"hint" : "open",
					"text" : "open setup audio",
					"outlettype" : [ "" ],
					"patching_rect" : [ 390.0, 94.0, 103.0, 18.0 ],
					"fontsize" : 12.0,
					"id" : "obj-3",
					"numinlets" : 2,
					"fontname" : "Arial",
					"numoutlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "panel",
					"border" : 1,
					"patching_rect" : [ 319.0, 54.0, 185.0, 261.0 ],
					"id" : "obj-53",
					"background" : 1,
					"grad1" : [ 0.262745, 0.423529, 1.0, 1.0 ],
					"bgcolor" : [ 1.0, 0.807843, 0.619608, 1.0 ],
					"numinlets" : 1,
					"grad2" : [ 0.329412, 0.329412, 1.0, 1.0 ],
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "panel",
					"border" : 1,
					"patching_rect" : [ 54.0, 244.0, 235.0, 68.0 ],
					"id" : "obj-49",
					"background" : 1,
					"grad1" : [ 0.262745, 0.423529, 1.0, 1.0 ],
					"bgcolor" : [ 0.035294, 0.635294, 0.831373, 1.0 ],
					"numinlets" : 1,
					"grad2" : [ 0.329412, 0.329412, 1.0, 1.0 ],
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "panel",
					"border" : 1,
					"patching_rect" : [ 54.0, 66.0, 233.0, 68.0 ],
					"id" : "obj-47",
					"background" : 1,
					"grad1" : [ 0.262745, 0.423529, 1.0, 1.0 ],
					"bgcolor" : [ 0.035294, 0.635294, 0.831373, 1.0 ],
					"numinlets" : 1,
					"grad2" : [ 0.329412, 0.329412, 1.0, 1.0 ],
					"numoutlets" : 0
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "panel",
					"border" : 1,
					"patching_rect" : [ 29.0, 11.0, 496.0, 355.0 ],
					"id" : "obj-33",
					"background" : 1,
					"bgcolor" : [ 0.776471, 0.776471, 0.776471, 1.0 ],
					"numinlets" : 1,
					"numoutlets" : 0
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"source" : [ "obj-11", 0 ],
					"destination" : [ "obj-17", 0 ],
					"hidden" : 0,
					"midpoints" : [ 346.5, 309.0, 325.5, 309.0 ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-17", 0 ],
					"destination" : [ "obj-1", 0 ],
					"hidden" : 0,
					"midpoints" : [ 325.5, 345.0, 39.0, 345.0, 39.0, 165.0, 70.5, 165.0 ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-83", 0 ],
					"destination" : [ "obj-1", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-78", 0 ],
					"destination" : [ "obj-15", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-54", 0 ],
					"destination" : [ "obj-83", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-46", 0 ],
					"destination" : [ "obj-11", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-3", 0 ],
					"destination" : [ "obj-46", 0 ],
					"hidden" : 0,
					"midpoints" : [ 399.5, 123.0, 327.0, 123.0, 327.0, 63.0, 346.5, 63.0 ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-1", 0 ],
					"destination" : [ "obj-78", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
 ]
	}

}
