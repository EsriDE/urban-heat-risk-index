// "Urban Heat Analyzer"
// Copyright (C) 2024 Esri Deutschland GmbH
// Jan Tschada (j.tschada@esri.de)
//
// SPDX-License-Identifier: GPL-3.0-only
//
// Additional permission under GNU GPL version 3 section 7
//
// If you modify this Program, or any covered work, by linking or combining
// it with ArcGIS Maps SDK for Qt (or a modified version of that library),
// containing parts covered by the terms of ArcGIS Maps SDK for Qt,
// the licensors of this Program grant you additional permission to convey the resulting work.
// See <https://developers.arcgis.com/qt/> for further information.

#include "HeatRiskListModel.h"

#include "AttributeListModel.h"
#include "Feature.h"

using namespace Esri::ArcGISRuntime;


HeatRiskAnalysisGroup::HeatRiskAnalysisGroup(double heatRiskIndex)
    : m_heatRiskIndex(heatRiskIndex)
{

}

QString HeatRiskAnalysisGroup::name() const
{
    if (m_heatRiskFeatures.empty())
    {
        return "Unknown";
    }

    auto heatRiskFeatureAttributes = m_heatRiskFeatures.first()->attributes();
    return heatRiskFeatureAttributes->attributeValue("GRID_ID").toString();
}

double HeatRiskAnalysisGroup::heatRiskIndex() const
{
    return m_heatRiskIndex;
}

void HeatRiskAnalysisGroup::addFeature(Feature *heatRiskFeature)
{
    m_heatRiskFeatures.append(heatRiskFeature);
}


HeatRiskListModel::HeatRiskListModel(QObject *parent)
    : QAbstractListModel{parent}
{

}

void HeatRiskListModel::loadAnalysisGroups(const QList<HeatRiskAnalysisGroup> &analysisGroups)
{
    beginResetModel();
    m_analysisGroups = analysisGroups;
    endResetModel();

    // Emit that the full data has changed
    emit dataChanged(index(0,0), index(rowCount() - 1));
}

int HeatRiskListModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return m_analysisGroups.count();
}

QVariant HeatRiskListModel::data(const QModelIndex & index, int role) const {
    if (index.row() < 0 || index.row() >= m_analysisGroups.count())
        return QVariant();

    const HeatRiskAnalysisGroup &analysisGroup = m_analysisGroups[index.row()];
    if (role == NameRole)
        return analysisGroup.name();
    else if (role == RiskRole)
        return analysisGroup.heatRiskIndex();
    return QVariant();
}

QHash<int, QByteArray> HeatRiskListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[RiskRole] = "risk";
    return roles;
}
