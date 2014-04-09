## Design Studio Feedback ##

#### Authors: Renzo Lucioni and Kathy Lin ####

We received feedback on our project from *Ina Chen* and *Manny "Fox" Morone*. After listening to an overview of our project and being shown a demo of our current implementation, Ina and Fox proceeded to give us both fair and helpful feedback. We're grateful for their input.

They first noted that we might want to think about making the national trend line a different color which stands our more readily against the multitude of green lines on the parallel coordinates plot. They initially suggested using white or a warmer color such as orange. However, after being shown how a right-clicked county is filled with black on the parallel coordinates plot, they suggested that we have the selected county line fill with orange and the national trend line fill with navy. We intend to address this feedback by having the selected county line fill with a warm color such as orange and the national trend line fill with a darker color such as navy.

Ina and Fox then suggested that we somehow differentiate counties with missing data from counties which are not selected on the parallel coordinates plot. Currently, both kinds of counties appear in gray. We intend to address this feedback by using either different shades of gray, some kind of fill pattern, or different colors to distinguish these counties from each other.

Ina and Fox proceeded to recommend that we make it clear to the user which county has been zoomed and centered on. Currently, it is hard for the user to tell which county they have clicked on, which by extension makes it difficult for them to zoom back out if the map background is not in view. We intend to address this feedback by decreasing the opacity of the focused county, as we do when a county is hovered over.

Ina and Fox also suggested that we add more a little more information to the tooltip shown on county hover. Currently, the tooltip displays the county's name and the state in which it is located. They suggested that we add the relevant statistic (i.e., the statistic on which the county is colored) to the tooltip. We intend to add this in a future revision of our project.

In addition, Ina and Fox noted that our work might benefit from some expanded instructions which explain to a user how to interact with our work; these instructions could be show as tooltips which disappear after the user clicks them. In particular, they said that the slider located on the line graph's horizontal axis might benefit from some text shown on the initial hover, which gives instructions on how it should be used. Fox also mentioned that we could consider adding some buffer to the vertical axis, both above the highest point on the graph and below the lowest point on the graph, so that the points don't get too close to the title or the axes. We will think more carefully about how to present instructions to the user in future revisions, and may pursue a strategy similar to the one described by Ina and Fox.

As for increasing detail on zoom to show ZIP code regions - one of optional features - Ina and Fox noted that no one thinks of the country in terms of ZIP codes, and as such they suggested that we not implement this feature. We agree with them on this point, and have decided not to pursue this avenue.
