#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: IIST - INSPIRE Ground Station
# Author: IIST
# Description: Copyright 2021 IIST, Thiruvananthapuram
# GNU Radio version: 3.7.14.0
##################################################

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print "Warning: failed to XInitThreads()"

from PyQt4 import Qt
from gnuradio import analog
from gnuradio import blocks
from gnuradio import digital
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio import qtgui
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from gnuradio.filter import pfb
from gnuradio.qtgui import Range, RangeWidget
from optparse import OptionParser
import ais
import math
import pmt
import sip
import sys
from gnuradio import qtgui


class IIST_IS1_UHF_SDR_v1(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "IIST - INSPIRE Ground Station")
        Qt.QWidget.__init__(self)
        self.setWindowTitle("IIST - INSPIRE Ground Station")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except:
            pass
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "IIST_IS1_UHF_SDR_v1")
        self.restoreGeometry(self.settings.value("geometry").toByteArray())


        ##################################################
        # Variables
        ##################################################
        self.symbol_rate = symbol_rate = 9600
        self.Fdeviation = Fdeviation = 4800
        self.system_clock = system_clock = 30720000
        self.sps = sps = 10
        self.h_index = h_index = 2.0*Fdeviation/symbol_rate
        self.BaudF = BaudF = symbol_rate/9600
        self.tx_gain = tx_gain = 66
        self.tx_freq = tx_freq = 437.5e6
        self.sensitivity = sensitivity = math.pi*h_index/sps
        self.samp_rate = samp_rate = system_clock/100
        self.rx_gain = rx_gain = 34
        self.rx_freq = rx_freq = 437.5e6
        self.re_samp_rate = re_samp_rate = 96000*BaudF
        self.cutoff = cutoff = 9e3
        self.corr_tx_freq = corr_tx_freq = 437500e3
        self.corr_rx_freq = corr_rx_freq = 437500e3
        self.IS1_re_samp_rate = IS1_re_samp_rate = 96000*BaudF

        ##################################################
        # Blocks
        ##################################################
        self.tab = Qt.QTabWidget()
        self.tab_widget_0 = Qt.QWidget()
        self.tab_layout_0 = Qt.QBoxLayout(Qt.QBoxLayout.TopToBottom, self.tab_widget_0)
        self.tab_grid_layout_0 = Qt.QGridLayout()
        self.tab_layout_0.addLayout(self.tab_grid_layout_0)
        self.tab.addTab(self.tab_widget_0, 'RF Signal')
        self.top_grid_layout.addWidget(self.tab)
        self._sensitivity_range = Range(0, 1, 0.01, math.pi*h_index/sps, 200)
        self._sensitivity_win = RangeWidget(self._sensitivity_range, self.set_sensitivity, "sensitivity", "counter_slider", float)
        self.top_grid_layout.addWidget(self._sensitivity_win, 2, 0, 1, 1)
        for r in range(2, 3):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._tx_gain_range = Range(0, 68, 1, 66, 200)
        self._tx_gain_win = RangeWidget(self._tx_gain_range, self.set_tx_gain, 'tx_gain', "counter_slider", int)
        self.top_grid_layout.addWidget(self._tx_gain_win, 4, 0, 1, 1)
        for r in range(4, 5):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._rx_gain_range = Range(0, 100, 1, 34, 200)
        self._rx_gain_win = RangeWidget(self._rx_gain_range, self.set_rx_gain, 'rx_gain', "counter_slider", float)
        self.top_grid_layout.addWidget(self._rx_gain_win, 3, 0, 1, 1)
        for r in range(3, 4):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self.qtgui_waterfall_sink_x_0_0 = qtgui.waterfall_sink_c(
        	1024, #size
        	firdes.WIN_BLACKMAN_hARRIS, #wintype
        	0, #fc
        	IS1_re_samp_rate, #bw
        	"", #name
                1 #number of inputs
        )
        self.qtgui_waterfall_sink_x_0_0.set_update_time(0.10)
        self.qtgui_waterfall_sink_x_0_0.enable_grid(False)
        self.qtgui_waterfall_sink_x_0_0.enable_axis_labels(True)

        if not True:
          self.qtgui_waterfall_sink_x_0_0.disable_legend()

        if "complex" == "float" or "complex" == "msg_float":
          self.qtgui_waterfall_sink_x_0_0.set_plot_pos_half(not True)

        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        colors = [5, 0, 0, 0, 0,
                  0, 0, 0, 0, 0]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]
        for i in xrange(1):
            if len(labels[i]) == 0:
                self.qtgui_waterfall_sink_x_0_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_waterfall_sink_x_0_0.set_line_label(i, labels[i])
            self.qtgui_waterfall_sink_x_0_0.set_color_map(i, colors[i])
            self.qtgui_waterfall_sink_x_0_0.set_line_alpha(i, alphas[i])

        self.qtgui_waterfall_sink_x_0_0.set_intensity_range(-120, -30)

        self._qtgui_waterfall_sink_x_0_0_win = sip.wrapinstance(self.qtgui_waterfall_sink_x_0_0.pyqwidget(), Qt.QWidget)
        self.tab_grid_layout_0.addWidget(self._qtgui_waterfall_sink_x_0_0_win, 0, 0, 1, 1)
        for r in range(0, 1):
            self.tab_grid_layout_0.setRowStretch(r, 1)
        for c in range(0, 1):
            self.tab_grid_layout_0.setColumnStretch(c, 1)
        self.qtgui_freq_sink_x_0_0 = qtgui.freq_sink_c(
        	1024, #size
        	firdes.WIN_BLACKMAN_hARRIS, #wintype
        	0, #fc
        	IS1_re_samp_rate, #bw
        	"", #name
        	1 #number of inputs
        )
        self.qtgui_freq_sink_x_0_0.set_update_time(0.20)
        self.qtgui_freq_sink_x_0_0.set_y_axis(-100, -30)
        self.qtgui_freq_sink_x_0_0.set_y_label('Relative Gain', 'dB')
        self.qtgui_freq_sink_x_0_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, 0.0, 0, "")
        self.qtgui_freq_sink_x_0_0.enable_autoscale(False)
        self.qtgui_freq_sink_x_0_0.enable_grid(False)
        self.qtgui_freq_sink_x_0_0.set_fft_average(1.0)
        self.qtgui_freq_sink_x_0_0.enable_axis_labels(True)
        self.qtgui_freq_sink_x_0_0.enable_control_panel(True)

        if not False:
          self.qtgui_freq_sink_x_0_0.disable_legend()

        if "complex" == "float" or "complex" == "msg_float":
          self.qtgui_freq_sink_x_0_0.set_plot_pos_half(not True)

        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        colors = ["green", "red", "green", "black", "cyan",
                  "magenta", "yellow", "dark red", "dark green", "dark blue"]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]
        for i in xrange(1):
            if len(labels[i]) == 0:
                self.qtgui_freq_sink_x_0_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_freq_sink_x_0_0.set_line_label(i, labels[i])
            self.qtgui_freq_sink_x_0_0.set_line_width(i, widths[i])
            self.qtgui_freq_sink_x_0_0.set_line_color(i, colors[i])
            self.qtgui_freq_sink_x_0_0.set_line_alpha(i, alphas[i])

        self._qtgui_freq_sink_x_0_0_win = sip.wrapinstance(self.qtgui_freq_sink_x_0_0.pyqwidget(), Qt.QWidget)
        self.tab_grid_layout_0.addWidget(self._qtgui_freq_sink_x_0_0_win, 0, 1, 1, 1)
        for r in range(0, 1):
            self.tab_grid_layout_0.setRowStretch(r, 1)
        for c in range(1, 2):
            self.tab_grid_layout_0.setColumnStretch(c, 1)
        self.pfb_arb_resampler_xxx_0_2 = pfb.arb_resampler_ccf(
        	  1.0*re_samp_rate/samp_rate,
                  taps=None,
        	  flt_size=32)
        self.pfb_arb_resampler_xxx_0_2.declare_sample_delay(0)

        self.low_pass_filter_0_0 = filter.fir_filter_ccf(1, firdes.low_pass(
        	1, samp_rate, cutoff, 2e3, firdes.WIN_BLACKMAN, 6.76))
        self.freq_xlating_fir_filter_xxx_0 = filter.freq_xlating_fir_filter_ccf(1, (firdes.low_pass_2(1,re_samp_rate,cutoff,1000,1)), 0, re_samp_rate)
        self.digital_hdlc_deframer_bp_0_0 = digital.hdlc_deframer_bp(32, 500)
        self.digital_gfsk_demod_0 = digital.gfsk_demod(
        	samples_per_symbol=10,
        	sensitivity=sensitivity,
        	gain_mu=0.175,
        	mu=0.5,
        	omega_relative_limit=0.005,
        	freq_error=0.0,
        	verbose=True,
        	log=False,
        )
        self.digital_diff_decoder_bb_0_0 = digital.diff_decoder_bb(2)
        self.digital_descrambler_bb_0_0 = digital.descrambler_bb(0x00021, 0, 16)
        self.blocks_throttle_0 = blocks.throttle(gr.sizeof_gr_complex*1, samp_rate,True)
        self.blocks_socket_pdu_0_0 = blocks.socket_pdu("TCP_CLIENT", 'localhost', '50001', 10000, True)
        self.blocks_multiply_xx_1 = blocks.multiply_vcc(1)
        self.blocks_message_debug_0_1 = blocks.message_debug()
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_gr_complex*1, '/home/uhf-sdr/IS-1/is1.bin', True)
        self.blocks_file_source_0.set_begin_tag(pmt.PMT_NIL)
        self.analog_simple_squelch_cc_0 = analog.simple_squelch_cc(-80, 1)
        self.ais_invert_0_0 = ais.invert()
        self.LO = analog.sig_source_c(samp_rate, analog.GR_COS_WAVE, 100000+rx_freq-corr_rx_freq, 1, 0)



        ##################################################
        # Connections
        ##################################################
        self.msg_connect((self.digital_hdlc_deframer_bp_0_0, 'out'), (self.blocks_message_debug_0_1, 'print_pdu'))
        self.msg_connect((self.digital_hdlc_deframer_bp_0_0, 'out'), (self.blocks_socket_pdu_0_0, 'pdus'))
        self.connect((self.LO, 0), (self.blocks_multiply_xx_1, 1))
        self.connect((self.ais_invert_0_0, 0), (self.digital_hdlc_deframer_bp_0_0, 0))
        self.connect((self.analog_simple_squelch_cc_0, 0), (self.freq_xlating_fir_filter_xxx_0, 0))
        self.connect((self.analog_simple_squelch_cc_0, 0), (self.qtgui_freq_sink_x_0_0, 0))
        self.connect((self.blocks_file_source_0, 0), (self.blocks_throttle_0, 0))
        self.connect((self.blocks_multiply_xx_1, 0), (self.low_pass_filter_0_0, 0))
        self.connect((self.blocks_throttle_0, 0), (self.blocks_multiply_xx_1, 0))
        self.connect((self.digital_descrambler_bb_0_0, 0), (self.digital_diff_decoder_bb_0_0, 0))
        self.connect((self.digital_diff_decoder_bb_0_0, 0), (self.ais_invert_0_0, 0))
        self.connect((self.digital_gfsk_demod_0, 0), (self.digital_descrambler_bb_0_0, 0))
        self.connect((self.freq_xlating_fir_filter_xxx_0, 0), (self.digital_gfsk_demod_0, 0))
        self.connect((self.low_pass_filter_0_0, 0), (self.pfb_arb_resampler_xxx_0_2, 0))
        self.connect((self.pfb_arb_resampler_xxx_0_2, 0), (self.analog_simple_squelch_cc_0, 0))
        self.connect((self.pfb_arb_resampler_xxx_0_2, 0), (self.qtgui_waterfall_sink_x_0_0, 0))

    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "IIST_IS1_UHF_SDR_v1")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()

    def get_symbol_rate(self):
        return self.symbol_rate

    def set_symbol_rate(self, symbol_rate):
        self.symbol_rate = symbol_rate
        self.set_h_index(2.0*self.Fdeviation/self.symbol_rate)
        self.set_BaudF(self.symbol_rate/9600)

    def get_Fdeviation(self):
        return self.Fdeviation

    def set_Fdeviation(self, Fdeviation):
        self.Fdeviation = Fdeviation
        self.set_h_index(2.0*self.Fdeviation/self.symbol_rate)

    def get_system_clock(self):
        return self.system_clock

    def set_system_clock(self, system_clock):
        self.system_clock = system_clock
        self.set_samp_rate(self.system_clock/100)

    def get_sps(self):
        return self.sps

    def set_sps(self, sps):
        self.sps = sps
        self.set_sensitivity(math.pi*self.h_index/self.sps)

    def get_h_index(self):
        return self.h_index

    def set_h_index(self, h_index):
        self.h_index = h_index
        self.set_sensitivity(math.pi*self.h_index/self.sps)

    def get_BaudF(self):
        return self.BaudF

    def set_BaudF(self, BaudF):
        self.BaudF = BaudF
        self.set_re_samp_rate(96000*self.BaudF)
        self.set_IS1_re_samp_rate(96000*self.BaudF)

    def get_tx_gain(self):
        return self.tx_gain

    def set_tx_gain(self, tx_gain):
        self.tx_gain = tx_gain

    def get_tx_freq(self):
        return self.tx_freq

    def set_tx_freq(self, tx_freq):
        self.tx_freq = tx_freq

    def get_sensitivity(self):
        return self.sensitivity

    def set_sensitivity(self, sensitivity):
        self.sensitivity = sensitivity

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.pfb_arb_resampler_xxx_0_2.set_rate(1.0*self.re_samp_rate/self.samp_rate)
        self.low_pass_filter_0_0.set_taps(firdes.low_pass(1, self.samp_rate, self.cutoff, 2e3, firdes.WIN_BLACKMAN, 6.76))
        self.blocks_throttle_0.set_sample_rate(self.samp_rate)
        self.LO.set_sampling_freq(self.samp_rate)

    def get_rx_gain(self):
        return self.rx_gain

    def set_rx_gain(self, rx_gain):
        self.rx_gain = rx_gain

    def get_rx_freq(self):
        return self.rx_freq

    def set_rx_freq(self, rx_freq):
        self.rx_freq = rx_freq
        self.LO.set_frequency(100000+self.rx_freq-self.corr_rx_freq)

    def get_re_samp_rate(self):
        return self.re_samp_rate

    def set_re_samp_rate(self, re_samp_rate):
        self.re_samp_rate = re_samp_rate
        self.pfb_arb_resampler_xxx_0_2.set_rate(1.0*self.re_samp_rate/self.samp_rate)
        self.freq_xlating_fir_filter_xxx_0.set_taps((firdes.low_pass_2(1,self.re_samp_rate,self.cutoff,1000,1)))

    def get_cutoff(self):
        return self.cutoff

    def set_cutoff(self, cutoff):
        self.cutoff = cutoff
        self.low_pass_filter_0_0.set_taps(firdes.low_pass(1, self.samp_rate, self.cutoff, 2e3, firdes.WIN_BLACKMAN, 6.76))
        self.freq_xlating_fir_filter_xxx_0.set_taps((firdes.low_pass_2(1,self.re_samp_rate,self.cutoff,1000,1)))

    def get_corr_tx_freq(self):
        return self.corr_tx_freq

    def set_corr_tx_freq(self, corr_tx_freq):
        self.corr_tx_freq = corr_tx_freq

    def get_corr_rx_freq(self):
        return self.corr_rx_freq

    def set_corr_rx_freq(self, corr_rx_freq):
        self.corr_rx_freq = corr_rx_freq
        self.LO.set_frequency(100000+self.rx_freq-self.corr_rx_freq)

    def get_IS1_re_samp_rate(self):
        return self.IS1_re_samp_rate

    def set_IS1_re_samp_rate(self, IS1_re_samp_rate):
        self.IS1_re_samp_rate = IS1_re_samp_rate
        self.qtgui_waterfall_sink_x_0_0.set_frequency_range(0, self.IS1_re_samp_rate)
        self.qtgui_freq_sink_x_0_0.set_frequency_range(0, self.IS1_re_samp_rate)


def main(top_block_cls=IIST_IS1_UHF_SDR_v1, options=None):

    from distutils.version import StrictVersion
    if StrictVersion(Qt.qVersion()) >= StrictVersion("4.5.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()
    tb.start()
    tb.show()

    def quitting():
        tb.stop()
        tb.wait()
    qapp.connect(qapp, Qt.SIGNAL("aboutToQuit()"), quitting)
    qapp.exec_()


if __name__ == '__main__':
    main()
