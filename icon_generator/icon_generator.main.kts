@file:Repository("https://repo1.maven.org/maven2/")
@file:DependsOn("com.twelvemonkeys.imageio:imageio-batik:3.8.3")
@file:DependsOn("org.apache.xmlgraphics:batik-transcoder:1.14")
@file:DependsOn("com.github.imcdonagh:image4j:0.7.2")

import net.sf.image4j.codec.ico.ICOEncoder
import java.awt.Image
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import javax.imageio.stream.FileImageOutputStream

val source = ImageIO.read(File("./logo.svg"))

fun Image.resize(size: Int) =
    BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB).apply {
        createGraphics().run {
            drawImage(this@resize.getScaledInstance(size, size, Image.SCALE_SMOOTH), 0, 0, null)
            dispose()
        }
    }

ICOEncoder.write(source.resize(64), File("../svg2iv_gui/windows/runner/resources/app_icon.ico"))

ImageIO.getImageWritersBySuffix("png").next().run {
    for (size in arrayOf(16, 192, 512)) {
        val fileName = if (size == 16) "favicon.png" else "icons/Icon-$size.png"
        FileImageOutputStream(File("../svg2iv_web/web/$fileName")).use {
            output = it
            write(source.resize(size))
        }
    }
}
