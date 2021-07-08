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
from gnuradio import uhd
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from gnuradio.filter import pfb
from gnuradio.qtgui import Range, RangeWidget
from optparse import OptionParser
import ais
import kiss
import math
import sip
import sys
import time
import tr
from gnuradio import qtgui


class IIST_IS1_UHF_SDR_v1(gr.top_block, Qt.QWidget):

    def __init__(self, tx_freq_0=437.5e6, tx_offset=250e3):
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
        # Parameters
        ##################################################
        self.tx_freq_0 = tx_freq_0
        self.tx_offset = tx_offset

        ##################################################
        # Variables
        ##################################################
        self.system_clock = system_clock = 30720000
        self.symbol_rate = symbol_rate = 9600
        self.Fdeviation = Fdeviation = 4800
        self.sps = sps = 10
        self.samp_rate = samp_rate = system_clock/100
        self.h_index = h_index = 2.0*Fdeviation/symbol_rate
        self.baud = baud = 9600
        self.BaudF = BaudF = symbol_rate/9600
        self.tx_gain = tx_gain = 10
        self.tx_freq = tx_freq = 437.5e6
        self.tx_correct = tx_correct = 0
        self.sensitivity = sensitivity = math.pi*h_index/sps
        self.samps_per_symb = samps_per_symb = samp_rate/baud
        self.rx_gain = rx_gain = 34
        self.rx_freq = rx_freq = 437.5e6
        self.re_samp_rate = re_samp_rate = 96000*BaudF
        self.interp = interp = 25
        self.decim = decim = 24
        self.cutoff = cutoff = 9e3
        self.corr_tx_freq_0 = corr_tx_freq_0 = 437.5e6
        self.corr_tx_freq = corr_tx_freq = 437500e3
        self.corr_rx_freq = corr_rx_freq = 437500e3
        self.bb_gain = bb_gain = .95
        self.alpha = alpha = .5
        self.IS1_re_samp_rate = IS1_re_samp_rate = 96000*BaudF

        ##################################################
        # Blocks
        ##################################################
        self._tx_gain_range = Range(0, 86, 1, 10, 200)
        self._tx_gain_win = RangeWidget(self._tx_gain_range, self.set_tx_gain, 'tx_gain', "counter_slider", int)
        self.top_grid_layout.addWidget(self._tx_gain_win, 4, 0, 1, 1)
        for r in range(4, 5):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._tx_correct_range = Range(-10000, 10000, 1, 0, 200)
        self._tx_correct_win = RangeWidget(self._tx_correct_range, self.set_tx_correct, "tx_correct", "counter_slider", float)
        self.top_grid_layout.addWidget(self._tx_correct_win, 8, 0, 1, 4)
        for r in range(8, 9):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 4):
            self.top_grid_layout.setColumnStretch(c, 1)
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
        self._rx_gain_range = Range(0, 100, 1, 34, 200)
        self._rx_gain_win = RangeWidget(self._rx_gain_range, self.set_rx_gain, 'rx_gain', "counter_slider", float)
        self.top_grid_layout.addWidget(self._rx_gain_win, 3, 0, 1, 1)
        for r in range(3, 4):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._bb_gain_range = Range(0, 1, .01, .95, 200)
        self._bb_gain_win = RangeWidget(self._bb_gain_range, self.set_bb_gain, 'bb_gain', "counter_slider", float)
        self.top_grid_layout.addWidget(self._bb_gain_win, 6, 0, 1, 4)
        for r in range(6, 7):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 4):
            self.top_grid_layout.setColumnStretch(c, 1)
        self.uhd_usrp_source_0_0 = uhd.usrp_source(
        	",".join(("", "")),
        	uhd.stream_args(
        		cpu_format="fc32",
        		channels=range(1),
        	),
        )
        self.uhd_usrp_source_0_0.set_samp_rate(samp_rate)
        self.uhd_usrp_source_0_0.set_center_freq(rx_freq+100000, 0)
        self.uhd_usrp_source_0_0.set_gain(rx_gain, 0)
        self.uhd_usrp_source_0_0.set_antenna('RX2', 0)
        self.uhd_usrp_source_0_0.set_bandwidth(30000, 0)
        self.uhd_usrp_source_0_0.set_auto_dc_offset(True, 0)
        self.uhd_usrp_source_0_0.set_auto_iq_balance(True, 0)
        self.uhd_usrp_sink_0_0 = uhd.usrp_sink(
        	",".join(("", "")),
        	uhd.stream_args(
        		cpu_format="fc32",
        		channels=range(1),
        	),
        )
        self.uhd_usrp_sink_0_0.set_samp_rate(250e3)
        self.uhd_usrp_sink_0_0.set_time_now(uhd.time_spec(time.time()), uhd.ALL_MBOARDS)
        self.uhd_usrp_sink_0_0.set_center_freq(uhd.tune_request(tx_freq+tx_correct, tx_offset), 0)
        self.uhd_usrp_sink_0_0.set_gain(tx_gain, 0)
        self.uhd_usrp_sink_0_0.set_antenna('TX/RX', 0)
        self.tr_tr_switch_cc_0 = tr.tr_switch_cc(self.get_corr_tx_freq)
        self.rational_resampler_xxx_0 = filter.rational_resampler_ccc(
                interpolation=interp,
                decimation=decim,
                taps=None,
                fractional_bw=None,
        )
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
        self.kiss_nrzi_encode_0 = kiss.nrzi_encode()
        self.kiss_hdlc_framer_0 = kiss.hdlc_framer(preamble_bytes=64, postamble_bytes=64)
        self.freq_xlating_fir_filter_xxx_0 = filter.freq_xlating_fir_filter_ccf(1, (firdes.low_pass_2(1,re_samp_rate,cutoff,1000,1)), 0, re_samp_rate)
        self.digital_scrambler_bb_0 = digital.scrambler_bb(0x21, 0x0, 16)
        self.digital_hdlc_deframer_bp_0_0 = digital.hdlc_deframer_bp(32, 500)
        self.digital_gfsk_mod_0 = digital.gfsk_mod(
        	samples_per_symbol=int(samps_per_symb),
        	sensitivity=0.1,
        	bt=alpha,
        	verbose=False,
        	log=False,
        )
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
        self.blocks_tag_gate_0 = blocks.tag_gate(gr.sizeof_gr_complex * 1, False)
        self.blocks_tag_gate_0.set_single_key("packet_len")
        self.blocks_socket_pdu_0_2 = blocks.socket_pdu("TCP_CLIENT", '0.0.0.0', '50000', 1024, False)
        self.blocks_socket_pdu_0_0 = blocks.socket_pdu("TCP_CLIENT", 'localhost', '50001', 10000, True)
        self.blocks_pdu_to_tagged_stream_0_0 = blocks.pdu_to_tagged_stream(blocks.byte_t, 'packet_len')
        self.blocks_pack_k_bits_bb_0 = blocks.pack_k_bits_bb(8)
        self.blocks_multiply_xx_1 = blocks.multiply_vcc(1)
        self.blocks_multiply_const_vxx_0_0 = blocks.multiply_const_vcc((bb_gain, ))
        self.blocks_message_debug_0_1 = blocks.message_debug()
        self.blocks_message_debug_0 = blocks.message_debug()
        self.analog_simple_squelch_cc_0 = analog.simple_squelch_cc(-80, 1)
        self.ais_invert_0_0 = ais.invert()
        self.LO = analog.sig_source_c(samp_rate, analog.GR_COS_WAVE, 100000+rx_freq-corr_rx_freq, 1, 0)



        ##################################################
        # Connections
        ##################################################
        self.msg_connect((self.blocks_socket_pdu_0_2, 'pdus'), (self.blocks_message_debug_0, 'print_pdu'))
        self.msg_connect((self.blocks_socket_pdu_0_2, 'pdus'), (self.kiss_hdlc_framer_0, 'in'))
        self.msg_connect((self.digital_hdlc_deframer_bp_0_0, 'out'), (self.blocks_message_debug_0_1, 'print_pdu'))
        self.msg_connect((self.digital_hdlc_deframer_bp_0_0, 'out'), (self.blocks_socket_pdu_0_0, 'pdus'))
        self.msg_connect((self.kiss_hdlc_framer_0, 'out'), (self.blocks_pdu_to_tagged_stream_0_0, 'pdus'))
        self.msg_connect((self.tr_tr_switch_cc_0, 'tx_freq'), (self.uhd_usrp_sink_0_0, 'command'))
        self.connect((self.LO, 0), (self.blocks_multiply_xx_1, 1))
        self.connect((self.ais_invert_0_0, 0), (self.digital_hdlc_deframer_bp_0_0, 0))
        self.connect((self.analog_simple_squelch_cc_0, 0), (self.freq_xlating_fir_filter_xxx_0, 0))
        self.connect((self.analog_simple_squelch_cc_0, 0), (self.qtgui_freq_sink_x_0_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0_0, 0), (self.rational_resampler_xxx_0, 0))
        self.connect((self.blocks_multiply_xx_1, 0), (self.low_pass_filter_0_0, 0))
        self.connect((self.blocks_pack_k_bits_bb_0, 0), (self.digital_gfsk_mod_0, 0))
        self.connect((self.blocks_pdu_to_tagged_stream_0_0, 0), (self.kiss_nrzi_encode_0, 0))
        self.connect((self.blocks_tag_gate_0, 0), (self.blocks_multiply_const_vxx_0_0, 0))
        self.connect((self.digital_descrambler_bb_0_0, 0), (self.digital_diff_decoder_bb_0_0, 0))
        self.connect((self.digital_diff_decoder_bb_0_0, 0), (self.ais_invert_0_0, 0))
        self.connect((self.digital_gfsk_demod_0, 0), (self.digital_descrambler_bb_0_0, 0))
        self.connect((self.digital_gfsk_mod_0, 0), (self.blocks_tag_gate_0, 0))
        self.connect((self.digital_scrambler_bb_0, 0), (self.blocks_pack_k_bits_bb_0, 0))
        self.connect((self.freq_xlating_fir_filter_xxx_0, 0), (self.digital_gfsk_demod_0, 0))
        self.connect((self.kiss_nrzi_encode_0, 0), (self.digital_scrambler_bb_0, 0))
        self.connect((self.low_pass_filter_0_0, 0), (self.pfb_arb_resampler_xxx_0_2, 0))
        self.connect((self.pfb_arb_resampler_xxx_0_2, 0), (self.analog_simple_squelch_cc_0, 0))
        self.connect((self.pfb_arb_resampler_xxx_0_2, 0), (self.qtgui_waterfall_sink_x_0_0, 0))
        self.connect((self.rational_resampler_xxx_0, 0), (self.tr_tr_switch_cc_0, 0))
        self.connect((self.tr_tr_switch_cc_0, 0), (self.uhd_usrp_sink_0_0, 0))
        self.connect((self.uhd_usrp_source_0_0, 0), (self.blocks_multiply_xx_1, 0))

    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "IIST_IS1_UHF_SDR_v1")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()

    def get_tx_freq_0(self):
        return self.tx_freq_0

    def set_tx_freq_0(self, tx_freq_0):
        self.tx_freq_0 = tx_freq_0

    def get_tx_offset(self):
        return self.tx_offset

    def set_tx_offset(self, tx_offset):
        self.tx_offset = tx_offset
        self.uhd_usrp_sink_0_0.set_center_freq(uhd.tune_request(self.tx_freq+self.tx_correct, self.tx_offset), 0)

    def get_system_clock(self):
        return self.system_clock

    def set_system_clock(self, system_clock):
        self.system_clock = system_clock
        self.set_samp_rate(self.system_clock/100)

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

    def get_sps(self):
        return self.sps

    def set_sps(self, sps):
        self.sps = sps
        self.set_sensitivity(math.pi*self.h_index/self.sps)

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.set_samps_per_symb(self.samp_rate/self.baud)
        self.uhd_usrp_source_0_0.set_samp_rate(self.samp_rate)
        self.pfb_arb_resampler_xxx_0_2.set_rate(1.0*self.re_samp_rate/self.samp_rate)
        self.low_pass_filter_0_0.set_taps(firdes.low_pass(1, self.samp_rate, self.cutoff, 2e3, firdes.WIN_BLACKMAN, 6.76))
        self.LO.set_sampling_freq(self.samp_rate)

    def get_h_index(self):
        return self.h_index

    def set_h_index(self, h_index):
        self.h_index = h_index
        self.set_sensitivity(math.pi*self.h_index/self.sps)

    def get_baud(self):
        return self.baud

    def set_baud(self, baud):
        self.baud = baud
        self.set_samps_per_symb(self.samp_rate/self.baud)

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
        self.uhd_usrp_sink_0_0.set_gain(self.tx_gain, 0)


    def get_tx_freq(self):
        return self.tx_freq

    def set_tx_freq(self, tx_freq):
        self.tx_freq = tx_freq
        self.uhd_usrp_sink_0_0.set_center_freq(uhd.tune_request(self.tx_freq+self.tx_correct, self.tx_offset), 0)

    def get_tx_correct(self):
        return self.tx_correct

    def set_tx_correct(self, tx_correct):
        self.tx_correct = tx_correct
        self.uhd_usrp_sink_0_0.set_center_freq(uhd.tune_request(self.tx_freq+self.tx_correct, self.tx_offset), 0)

    def get_sensitivity(self):
        return self.sensitivity

    def set_sensitivity(self, sensitivity):
        self.sensitivity = sensitivity

    def get_samps_per_symb(self):
        return self.samps_per_symb

    def set_samps_per_symb(self, samps_per_symb):
        self.samps_per_symb = samps_per_symb

    def get_rx_gain(self):
        return self.rx_gain

    def set_rx_gain(self, rx_gain):
        self.rx_gain = rx_gain
        self.uhd_usrp_source_0_0.set_gain(self.rx_gain, 0)


    def get_rx_freq(self):
        return self.rx_freq

    def set_rx_freq(self, rx_freq):
        self.rx_freq = rx_freq
        self.uhd_usrp_source_0_0.set_center_freq(self.rx_freq+100000, 0)
        self.LO.set_frequency(100000+self.rx_freq-self.corr_rx_freq)

    def get_re_samp_rate(self):
        return self.re_samp_rate

    def set_re_samp_rate(self, re_samp_rate):
        self.re_samp_rate = re_samp_rate
        self.pfb_arb_resampler_xxx_0_2.set_rate(1.0*self.re_samp_rate/self.samp_rate)
        self.freq_xlating_fir_filter_xxx_0.set_taps((firdes.low_pass_2(1,self.re_samp_rate,self.cutoff,1000,1)))

    def get_interp(self):
        return self.interp

    def set_interp(self, interp):
        self.interp = interp

    def get_decim(self):
        return self.decim

    def set_decim(self, decim):
        self.decim = decim

    def get_cutoff(self):
        return self.cutoff

    def set_cutoff(self, cutoff):
        self.cutoff = cutoff
        self.low_pass_filter_0_0.set_taps(firdes.low_pass(1, self.samp_rate, self.cutoff, 2e3, firdes.WIN_BLACKMAN, 6.76))
        self.freq_xlating_fir_filter_xxx_0.set_taps((firdes.low_pass_2(1,self.re_samp_rate,self.cutoff,1000,1)))

    def get_corr_tx_freq_0(self):
        return self.corr_tx_freq_0

    def set_corr_tx_freq_0(self, corr_tx_freq_0):
        self.corr_tx_freq_0 = corr_tx_freq_0

    def get_corr_tx_freq(self):
        return self.corr_tx_freq

    def set_corr_tx_freq(self, corr_tx_freq):
        self.corr_tx_freq = corr_tx_freq

    def get_corr_rx_freq(self):
        return self.corr_rx_freq

    def set_corr_rx_freq(self, corr_rx_freq):
        self.corr_rx_freq = corr_rx_freq
        self.LO.set_frequency(100000+self.rx_freq-self.corr_rx_freq)

    def get_bb_gain(self):
        return self.bb_gain

    def set_bb_gain(self, bb_gain):
        self.bb_gain = bb_gain
        self.blocks_multiply_const_vxx_0_0.set_k((self.bb_gain, ))

    def get_alpha(self):
        return self.alpha

    def set_alpha(self, alpha):
        self.alpha = alpha

    def get_IS1_re_samp_rate(self):
        return self.IS1_re_samp_rate

    def set_IS1_re_samp_rate(self, IS1_re_samp_rate):
        self.IS1_re_samp_rate = IS1_re_samp_rate
        self.qtgui_waterfall_sink_x_0_0.set_frequency_range(0, self.IS1_re_samp_rate)
        self.qtgui_freq_sink_x_0_0.set_frequency_range(0, self.IS1_re_samp_rate)


def argument_parser():
    description = 'Copyright 2021 IIST, Thiruvananthapuram'
    parser = OptionParser(usage="%prog: [options]", option_class=eng_option, description=description)
    parser.add_option(
        "", "--tx-freq-0", dest="tx_freq_0", type="eng_float", default=eng_notation.num_to_str(437.5e6),
        help="Set tx_freq_0 [default=%default]")
    parser.add_option(
        "", "--tx-offset", dest="tx_offset", type="eng_float", default=eng_notation.num_to_str(250e3),
        help="Set tx_offset [default=%default]")
    return parser


def main(top_block_cls=IIST_IS1_UHF_SDR_v1, options=None):
    if options is None:
        options, _ = argument_parser().parse_args()

    from distutils.version import StrictVersion
    if StrictVersion(Qt.qVersion()) >= StrictVersion("4.5.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls(tx_freq_0=options.tx_freq_0, tx_offset=options.tx_offset)
    tb.start()
    tb.show()

    def quitting():
        tb.stop()
        tb.wait()
    qapp.connect(qapp, Qt.SIGNAL("aboutToQuit()"), quitting)
    qapp.exec_()


if __name__ == '__main__':
    main()
