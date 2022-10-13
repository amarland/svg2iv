@file:Repository("https://repo1.maven.org/maven2/")
@file:DependsOn("com.twelvemonkeys.imageio:imageio-batik:3.8.3")
@file:DependsOn("org.apache.xmlgraphics:batik-transcoder:1.14")
@file:DependsOn("image4j-0.7.2.jar")

import net.sf.image4j.codec.ico.ICOEncoder
import java.io.File
import javax.imageio.ImageIO

ICOEncoder.write(
    ImageIO.read(File("../assets/logo.svg")),
    File("../windows/runner/resources/app_icon.ico")
)
