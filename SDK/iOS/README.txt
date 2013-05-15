This framework was created following the document:

https://github.com/jverkoey/iOS-Framework#walkthrough

However that document has a couple of errors. The correction of those errors is:

1)  In the target Build Settings tab set the Public Header Folders Path to include/$(TARGET_NAME).

2) When adding new sources to the framework the option to set the visibility of the library header to public is not available. To be able to set them public first select the target and select Editor -> Add Build Phase -> Add Copy Headers Build Phase. Then in the target Build Phases tab include the header sources added so they have the option to be modified through the Target Membership group of the Utilities pane.

3) Build the project with the "Framework" scheme selected.

4) Right click at "libRepublic.a" under "Products" and select "Show in Finder"

5) Copy Republic.framework and paste it into the app that uses the SDK (DemoWithFrameworkInclusion)

